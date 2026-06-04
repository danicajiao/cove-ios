DELETE FROM catalog.signals
WHERE code IN (
    'b_corp',
    'usda_organic',
    'fair_trade',
    'one_pct_planet',
    'colorado_proud',
    'living_wage',
    'identity_verified',
    'business_registered'
);
