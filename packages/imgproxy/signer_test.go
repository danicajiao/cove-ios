package imgproxy_test

import (
	"strings"
	"testing"
	"time"

	"github.com/danicajiao/cove/packages/imgproxy"
)

// testKey and testSalt are 32-byte (64 hex char) values used only in tests.
const (
	testKey  = "0000000000000000000000000000000000000000000000000000000000000001"
	testSalt = "0000000000000000000000000000000000000000000000000000000000000002"
)

func newTestSigner(t *testing.T) *imgproxy.Signer {
	t.Helper()
	s, err := imgproxy.NewSigner(testKey, testSalt, "https://imgproxy.example.com", "cove-media", time.Hour)
	if err != nil {
		t.Fatalf("NewSigner: %v", err)
	}
	return s
}

func TestNewSigner_InvalidKeyHex(t *testing.T) {
	_, err := imgproxy.NewSigner("not-hex!", testSalt, "http://x.com", "bucket", time.Hour)
	if err == nil {
		t.Error("expected error for invalid key hex, got nil")
	}
}

func TestNewSigner_InvalidSaltHex(t *testing.T) {
	_, err := imgproxy.NewSigner(testKey, "not-hex!", "http://x.com", "bucket", time.Hour)
	if err == nil {
		t.Error("expected error for invalid salt hex, got nil")
	}
}

func TestSign_URLStructure(t *testing.T) {
	s := newTestSigner(t)
	result := s.Sign("images/abc123.webp", 800, 800, imgproxy.FitCover)

	if !strings.HasPrefix(result.URL, "https://imgproxy.example.com/") {
		t.Errorf("URL should start with base URL, got: %s", result.URL)
	}
	if !strings.Contains(result.URL, "/exp:") {
		t.Errorf("URL should contain exp: processing option, got: %s", result.URL)
	}
	if !strings.Contains(result.URL, "/rs:fill:800:800/") {
		t.Errorf("URL should contain fill resize option for 800×800, got: %s", result.URL)
	}
	if !strings.Contains(result.URL, "plain/s3://cove-media/images/abc123.webp@webp") {
		t.Errorf("URL should contain S3 source with @webp suffix, got: %s", result.URL)
	}
}

func TestSign_FitContain(t *testing.T) {
	s := newTestSigner(t)
	result := s.Sign("images/abc123.webp", 400, 300, imgproxy.FitContain)

	if !strings.Contains(result.URL, "/rs:fit:400:300/") {
		t.Errorf("FitContain should use 'fit' resize type, got: %s", result.URL)
	}
}

func TestSign_ExpiryWindow(t *testing.T) {
	s := newTestSigner(t)
	before := time.Now()
	result := s.Sign("images/abc123.webp", 200, 200, imgproxy.FitCover)
	after := time.Now()

	minExpiry := before.Add(time.Hour)
	maxExpiry := after.Add(time.Hour + time.Second)
	if result.ExpiresAt.Before(minExpiry) || result.ExpiresAt.After(maxExpiry) {
		t.Errorf("ExpiresAt %v not in expected 1-hour window [%v, %v]",
			result.ExpiresAt, minExpiry, maxExpiry)
	}
}

func TestSign_SignatureIsDeterministic(t *testing.T) {
	// Two signers with identical credentials produce the same processing path
	// for the same inputs. Strip the /exp:... timestamp before comparing so
	// the test is not flaky across a 1-second boundary.
	s1 := newTestSigner(t)
	r1 := s1.Sign("images/abc.webp", 400, 400, imgproxy.FitCover)

	s2 := newTestSigner(t)
	r2 := s2.Sign("images/abc.webp", 400, 400, imgproxy.FitCover)

	stripExp := func(u string) string {
		if idx := strings.Index(u, "/rs:"); idx >= 0 {
			return u[idx:]
		}
		return u
	}
	if stripExp(r1.URL) != stripExp(r2.URL) {
		t.Errorf("same inputs produced different processing paths:\n  %s\n  %s", r1.URL, r2.URL)
	}
}

func TestParseFit(t *testing.T) {
	cases := []struct {
		input string
		want  imgproxy.FitType
	}{
		{"cover", imgproxy.FitCover},
		{"contain", imgproxy.FitContain},
		{"", imgproxy.FitCover},
		{"unknown", imgproxy.FitCover},
		{"COVER", imgproxy.FitCover}, // case-sensitive — unrecognised → default
	}
	for _, c := range cases {
		got := imgproxy.ParseFit(c.input)
		if got != c.want {
			t.Errorf("ParseFit(%q) = %q, want %q", c.input, got, c.want)
		}
	}
}

// TestSignVariants_ReturnedKeys verifies that SignVariants returns exactly the
// requested variant names as map keys.
func TestSignVariants_ReturnedKeys(t *testing.T) {
	s := newTestSigner(t)
	names := []string{"thumb", "sm", "md"}
	got := s.SignVariants("images/test.webp", names...)

	if len(got) != len(names) {
		t.Fatalf("SignVariants returned %d entries, want %d", len(got), len(names))
	}
	for _, name := range names {
		if _, ok := got[name]; !ok {
			t.Errorf("SignVariants missing key %q", name)
		}
	}
}

// TestSignVariants_AllFive verifies the full five-variant set used by detail endpoints.
func TestSignVariants_AllFive(t *testing.T) {
	s := newTestSigner(t)
	got := s.SignVariants("images/test.webp", "thumb", "sm", "md", "lg", "xl")

	if len(got) != 5 {
		t.Fatalf("expected 5 variants, got %d", len(got))
	}
	for _, name := range []string{"thumb", "sm", "md", "lg", "xl"} {
		url, ok := got[name]
		if !ok {
			t.Errorf("missing variant %q", name)
			continue
		}
		if !strings.HasPrefix(url, "https://imgproxy.example.com/") {
			t.Errorf("variant %q URL has wrong prefix: %s", name, url)
		}
		if !strings.Contains(url, "/rs:fill:") {
			t.Errorf("variant %q URL missing fill resize option: %s", name, url)
		}
	}
}

// TestSignVariants_Dimensions verifies that each named variant is signed with
// the correct pixel dimensions from the Catalog.
func TestSignVariants_Dimensions(t *testing.T) {
	s := newTestSigner(t)

	cases := []struct {
		name string
		want string // expected /rs:fill:W:H/ fragment
	}{
		{"thumb", "/rs:fill:200:200/"},
		{"sm", "/rs:fill:400:400/"},
		{"md", "/rs:fill:800:800/"},
		{"lg", "/rs:fill:1600:1600/"},
		{"xl", "/rs:fill:3200:3200/"},
	}

	got := s.SignVariants("images/test.webp", "thumb", "sm", "md", "lg", "xl")

	for _, tc := range cases {
		url, ok := got[tc.name]
		if !ok {
			t.Errorf("variant %q not returned", tc.name)
			continue
		}
		if !strings.Contains(url, tc.want) {
			t.Errorf("variant %q: expected %q in URL, got: %s", tc.name, tc.want, url)
		}
	}
}

// TestSignVariants_UnknownNameIgnored verifies that requesting a variant name
// not in the Catalog produces no entry rather than an error.
func TestSignVariants_UnknownNameIgnored(t *testing.T) {
	s := newTestSigner(t)
	got := s.SignVariants("images/test.webp", "thumb", "nonexistent")

	if _, ok := got["nonexistent"]; ok {
		t.Error("SignVariants should not return an entry for an unknown variant name")
	}
	if _, ok := got["thumb"]; !ok {
		t.Error("SignVariants should still return the valid variant")
	}
}
