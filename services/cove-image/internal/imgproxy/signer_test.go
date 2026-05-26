package imgproxy_test

import (
	"strings"
	"testing"
	"time"

	"github.com/danicajiao/cove/services/cove-image/internal/imgproxy"
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

func TestSign_ProducesValidURL(t *testing.T) {
	s := newTestSigner(t)
	result := s.Sign("images/abc123.png", 600, 600, imgproxy.FitCover)

	if !strings.HasPrefix(result.URL, "https://imgproxy.example.com/") {
		t.Errorf("URL should start with base URL, got: %s", result.URL)
	}
	if !strings.Contains(result.URL, "/rs:fill:600:600/") {
		t.Errorf("URL should contain fill resize option, got: %s", result.URL)
	}
	if !strings.Contains(result.URL, "s3://cove-media/images/abc123.png@webp") {
		t.Errorf("URL should contain S3 source with @webp format, got: %s", result.URL)
	}
}

func TestSign_FitContain(t *testing.T) {
	s := newTestSigner(t)
	result := s.Sign("images/abc123.jpg", 400, 300, imgproxy.FitContain)

	if !strings.Contains(result.URL, "/rs:fit:400:300/") {
		t.Errorf("contain fit should use 'fit' resize type, got: %s", result.URL)
	}
}

func TestSign_EmbedExpiry(t *testing.T) {
	s := newTestSigner(t)
	before := time.Now()
	result := s.Sign("images/abc123.png", 400, 400, imgproxy.FitCover)
	after := time.Now()

	if !strings.Contains(result.URL, "/exp:") {
		t.Errorf("URL should contain exp: option, got: %s", result.URL)
	}
	// ExpiresAt should be approximately 1 hour from now.
	minExpiry := before.Add(time.Hour)
	maxExpiry := after.Add(time.Hour + time.Second)
	if result.ExpiresAt.Before(minExpiry) || result.ExpiresAt.After(maxExpiry) {
		t.Errorf("ExpiresAt %v not in expected range [%v, %v]", result.ExpiresAt, minExpiry, maxExpiry)
	}
}

func TestSign_SignatureIsDeterministic(t *testing.T) {
	// Two signers with the same credentials produce the same URL for the same
	// inputs. We freeze time by signing twice within a single second — if the
	// unix timestamps match, the URLs must be identical.
	s1 := newTestSigner(t)
	r1 := s1.Sign("images/abc.png", 200, 200, imgproxy.FitCover)

	s2 := newTestSigner(t)
	r2 := s2.Sign("images/abc.png", 200, 200, imgproxy.FitCover)

	// Strip the /exp:... segment since timestamps may differ by ±1s across
	// calls. Instead just verify the non-expiry segments are stable.
	stripExp := func(u string) string {
		idx := strings.Index(u, "/rs:")
		if idx < 0 {
			return u
		}
		return u[idx:]
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

func TestNewSigner_InvalidKeyHex(t *testing.T) {
	_, err := imgproxy.NewSigner("not-hex!", testSalt, "http://x.com", "bucket", time.Hour)
	if err == nil {
		t.Error("expected error for invalid key hex")
	}
}

func TestNewSigner_InvalidSaltHex(t *testing.T) {
	_, err := imgproxy.NewSigner(testKey, "not-hex!", "http://x.com", "bucket", time.Hour)
	if err == nil {
		t.Error("expected error for invalid salt hex")
	}
}
