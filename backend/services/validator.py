import re

# State-specific vanity plate rules researched from PlateMonitor.com and state DMV sites
# Note: Rules are for standard passenger vehicle vanity plates.
# Motorcycle and specialty plates may have different limits.
STATE_RULES = {
    "AL": {"max_length": 7, "min_length": 2, "pattern": r"^[A-Z0-9 ]{2,7}$", "allowed_chars": "Letters, numbers, and spaces", "notes": "Alabama: 2-7 characters. $50/yr + $5 issuance fee."},
    "AK": {"max_length": 6, "min_length": 2, "pattern": r"^[A-Z0-9 ]{2,6}$", "allowed_chars": "Letters, numbers, and spaces", "notes": "Alaska: 2-6 characters."},
    "AZ": {"max_length": 7, "min_length": 2, "pattern": r"^[A-Z0-9 ]{2,7}$", "allowed_chars": "Letters, numbers, and spaces", "notes": "Arizona: 2-7 characters."},
    "AR": {"max_length": 7, "min_length": 2, "pattern": r"^[A-Z0-9 ]{2,7}$", "allowed_chars": "Letters, numbers, and spaces", "notes": "Arkansas: 2-7 characters."},
    "CA": {"max_length": 7, "min_length": 2, "pattern": r"^[A-Z0-9 ]{2,7}$", "allowed_chars": "Letters, numbers, and spaces", "notes": "California: 2-7 characters. Half spaces allowed."},
    "CO": {"max_length": 7, "min_length": 2, "pattern": r"^[A-Z0-9 ]{2,7}$", "allowed_chars": "Letters, numbers, and spaces", "notes": "Colorado: 2-7 characters. $60 one-time + $25/yr renewal."},
    "CT": {"max_length": 7, "min_length": 2, "pattern": r"^[A-Z0-9 ]{2,7}$", "allowed_chars": "Letters, numbers, and spaces", "notes": "Connecticut: 2-7 characters."},
    "DE": {"max_length": 7, "min_length": 1, "pattern": r"^[A-Z0-9 ]{1,7}$", "allowed_chars": "Letters, numbers, and spaces", "notes": "Delaware: 1-7 characters. New applications may be suspended."},
    "FL": {"max_length": 7, "min_length": 2, "pattern": r"^[A-Z0-9 -]{2,7}$", "allowed_chars": "Letters, numbers, spaces, and hyphens", "notes": "Florida: 2-7 characters. Spaces and hyphens count as characters."},
    "GA": {"max_length": 7, "min_length": 1, "pattern": r"^[A-Z0-9 ]{1,7}$", "allowed_chars": "Letters, numbers, and spaces", "notes": "Georgia: 1-7 characters. $90 initial + $55 renewal."},
    "HI": {"max_length": 6, "min_length": 2, "pattern": r"^[A-Z0-9 -]{2,6}$", "allowed_chars": "Letters, numbers, spaces, and one hyphen", "notes": "Hawaii: 2-6 characters. One hyphen allowed."},
    "ID": {"max_length": 7, "min_length": 1, "pattern": r"^[A-Z0-9 ]{1,7}$", "allowed_chars": "Letters (except O), numbers, and spaces", "notes": "Idaho: 1-7 characters. Letter O not allowed, use 0 instead."},
    "IL": {"max_length": 7, "min_length": 1, "pattern": r"^[A-Z0-9 ]{1,7}$", "allowed_chars": "Letters, numbers, and spaces", "notes": "Illinois: 1-7 characters."},
    "IN": {"max_length": 8, "min_length": 2, "pattern": r"^[A-Z0-9 ]{2,8}$", "allowed_chars": "Letters, numbers, and spaces", "notes": "Indiana: 2-8 characters. $45/yr."},
    "IA": {"max_length": 7, "min_length": 2, "pattern": r"^[A-Z0-9 ]{2,7}$", "allowed_chars": "Letters, numbers, and spaces", "notes": "Iowa: 2-7 characters."},
    "KS": {"max_length": 7, "min_length": 2, "pattern": r"^[A-Z0-9 ]{2,7}$", "allowed_chars": "Letters, numbers, and spaces", "notes": "Kansas: 2-7 characters. No symbols."},
    "KY": {"max_length": 6, "min_length": 2, "pattern": r"^[A-Z0-9 ]{2,6}$", "allowed_chars": "Letters (except I, Q, U), numbers, and spaces", "notes": "Kentucky: 2-6 characters. Letters I, Q, U not available."},
    "LA": {"max_length": 7, "min_length": 2, "pattern": r"^[A-Z0-9 ]{2,7}$", "allowed_chars": "Letters, numbers, and spaces", "notes": "Louisiana: 2-7 characters."},
    "ME": {"max_length": 7, "min_length": 2, "pattern": r"^[A-Z][A-Z0-9 &-]{1,6}$", "allowed_chars": "Letters, numbers, spaces, dash, and ampersand", "notes": "Maine: 2-7 characters. Must begin with a letter. $25/yr."},
    "MD": {"max_length": 7, "min_length": 2, "pattern": r"^[A-Z0-9 ]{2,7}$", "allowed_chars": "Letters, numbers, and spaces", "notes": "Maryland: 2-7 characters. $50/yr."},
    "MA": {"max_length": 6, "min_length": 2, "pattern": r"^[A-Z]{2,6}[0-9]*$", "allowed_chars": "Letters required first, numbers only at end", "notes": "Massachusetts: 2-6 characters. Must start with 2+ letters, numbers only at end."},
    "MI": {"max_length": 7, "min_length": 2, "pattern": r"^[A-Z0-9 ]{2,7}$", "allowed_chars": "Letters, numbers, and spaces", "notes": "Michigan: 2-7 characters."},
    "MN": {"max_length": 7, "min_length": 2, "pattern": r"^[A-Z0-9 ]{2,7}$", "allowed_chars": "Letters, numbers, and spaces", "notes": "Minnesota: 2-7 characters."},
    "MS": {"max_length": 7, "min_length": 2, "pattern": r"^[A-Z0-9 ]{2,7}$", "allowed_chars": "Letters, numbers, and spaces", "notes": "Mississippi: 2-7 characters. Only one space allowed."},
    "MO": {"max_length": 6, "min_length": 2, "pattern": r"^[A-Z0-9 '-]{2,6}$", "allowed_chars": "Letters, numbers, space, dash, or apostrophe", "notes": "Missouri: 2-6 characters. One special char (space, dash, or apostrophe) allowed."},
    "MT": {"max_length": 7, "min_length": 2, "pattern": r"^[A-Z0-9 ]{2,7}$", "allowed_chars": "Letters, numbers, and spaces", "notes": "Montana: 2-7 characters."},
    "NE": {"max_length": 7, "min_length": 2, "pattern": r"^[A-Z0-9 ]{2,7}$", "allowed_chars": "Letters, numbers, and one space", "notes": "Nebraska: 2-7 characters. One space allowed."},
    "NV": {"max_length": 7, "min_length": 1, "pattern": r"^[A-Z0-9 ]{1,7}$", "allowed_chars": "Letters, numbers, and spaces", "notes": "Nevada: 1-7 characters. $43.50 initial + $20/yr."},
    "NH": {"max_length": 7, "min_length": 2, "pattern": r"^[A-Z0-9 &+-]{2,7}$", "allowed_chars": "Letters, numbers, spaces, plus, minus, ampersand", "notes": "New Hampshire: 2-7 characters."},
    "NJ": {"max_length": 7, "min_length": 3, "pattern": r"^[A-Z0-9]{3,7}$", "allowed_chars": "Letters and numbers only", "notes": "New Jersey: 3-7 characters. No spaces or special characters."},
    "NM": {"max_length": 7, "min_length": 1, "pattern": r"^[A-Z0-9]{1,7}$", "allowed_chars": "Letters and numbers only", "notes": "New Mexico: 1-7 characters (up to 8 on turquoise plates). No special characters."},
    "NY": {"max_length": 8, "min_length": 2, "pattern": r"^[A-Z0-9 ]{2,8}$", "allowed_chars": "Letters, numbers, and spaces", "notes": "New York: 2-8 characters."},
    "NC": {"max_length": 8, "min_length": 2, "pattern": r"^[A-Z0-9 ]{2,8}$", "allowed_chars": "Letters, numbers, and spaces", "notes": "North Carolina: 2-8 characters."},
    "ND": {"max_length": 7, "min_length": 2, "pattern": r"^[A-Z0-9 ]{2,7}$", "allowed_chars": "Letters, numbers, and spaces", "notes": "North Dakota: 2-7 characters."},
    "OH": {"max_length": 7, "min_length": 4, "pattern": r"^[A-Z0-9 ]{4,7}$", "allowed_chars": "Letters, numbers, and spaces", "notes": "Ohio: 4-7 characters."},
    "OK": {"max_length": 7, "min_length": 4, "pattern": r"^[A-Z0-9 -]{4,7}$", "allowed_chars": "Letters, numbers, spaces, and hyphens", "notes": "Oklahoma: 4-7 characters."},
    "OR": {"max_length": 6, "min_length": 2, "pattern": r"^[A-Z0-9 ]{2,6}$", "allowed_chars": "Letters, numbers, and spaces", "notes": "Oregon: 2-6 characters. No punctuation."},
    "PA": {"max_length": 7, "min_length": 2, "pattern": r"^[A-Z0-9 -]{2,7}$", "allowed_chars": "Letters, numbers, spaces, and hyphens", "notes": "Pennsylvania: 2-7 characters."},
    "RI": {"max_length": 6, "min_length": 2, "pattern": r"^[A-Z0-9 ]{2,6}$", "allowed_chars": "Letters, numbers, and spaces", "notes": "Rhode Island: 2-6 characters."},
    "SC": {"max_length": 7, "min_length": 2, "pattern": r"^[A-Z0-9 &]{2,7}$", "allowed_chars": "Letters, numbers, spaces, and ampersand", "notes": "South Carolina: 2-7 characters. Mail-in application only."},
    "SD": {"max_length": 7, "min_length": 2, "pattern": r"^[A-Z0-9]{2,7}$", "allowed_chars": "Letters and numbers only", "notes": "South Dakota: 2-7 characters. No special characters."},
    "TN": {"max_length": 7, "min_length": 2, "pattern": r"^[A-Z0-9 ]{2,7}$", "allowed_chars": "Letters, numbers, and spaces", "notes": "Tennessee: 2-7 characters."},
    "TX": {"max_length": 7, "min_length": 2, "pattern": r"^[A-Z0-9 ]{2,7}$", "allowed_chars": "Letters, numbers, and spaces", "notes": "Texas: 2-7 characters. No hyphens. $70-$395/yr."},
    "UT": {"max_length": 7, "min_length": 2, "pattern": r"^[A-Z0-9 ]{2,7}$", "allowed_chars": "Letters (except O), numbers, and spaces", "notes": "Utah: 2-7 characters. Letter O not allowed, use 0 instead."},
    "VT": {"max_length": 7, "min_length": 2, "pattern": r"^[A-Z0-9]{2,7}$", "allowed_chars": "Letters and numbers only", "notes": "Vermont: 2-7 characters. Max 2 numbers allowed. O becomes 0."},
    "VA": {"max_length": 7, "min_length": 1, "pattern": r"^[A-Z0-9 -]{1,7}$", "allowed_chars": "Letters, numbers, spaces, and hyphens", "notes": "Virginia: 1-7 characters."},
    "WA": {"max_length": 7, "min_length": 1, "pattern": r"^[A-Z0-9 -]{1,7}$", "allowed_chars": "Letters, numbers, hyphens, and spaces", "notes": "Washington: 1-7 characters."},
    "WV": {"max_length": 8, "min_length": 2, "pattern": r"^[A-Z0-9 ]{2,8}$", "allowed_chars": "Letters, numbers, and spaces", "notes": "West Virginia: 2-8 characters."},
    "WI": {"max_length": 7, "min_length": 2, "pattern": r"^[A-Z0-9 ]{2,7}$", "allowed_chars": "Letters, numbers, and spaces", "notes": "Wisconsin: 2-7 characters."},
    "WY": {"max_length": 5, "min_length": 2, "pattern": r"^[A-Z0-9 ]{2,5}$", "allowed_chars": "Letters, numbers, and spaces", "notes": "Wyoming: 2-5 characters."},
    "DC": {"max_length": 7, "min_length": 2, "pattern": r"^[A-Z0-9 ]{2,7}$", "allowed_chars": "Letters, numbers, and spaces", "notes": "District of Columbia: 2-7 characters."},
}


def get_rules(state: str) -> dict | None:
    return STATE_RULES.get(state.upper())


def get_all_states() -> list[str]:
    return sorted(STATE_RULES.keys())


def validate_plate(plate: str, state: str = "GA") -> tuple[bool, str]:
    """Validate a plate string against state rules.

    Returns (is_valid, message).
    """
    rules = get_rules(state)
    if not rules:
        return False, f"Unsupported state: {state}"

    plate_upper = plate.upper().strip()

    if not plate_upper:
        return False, "Plate cannot be empty."

    if len(plate_upper) > rules["max_length"]:
        return False, f"Too long: max {rules['max_length']} characters (got {len(plate_upper)})."

    min_len = rules.get("min_length", 1)
    if len(plate_upper) < min_len:
        return False, f"Too short: min {min_len} characters (got {len(plate_upper)})."

    if not re.match(rules["pattern"], plate_upper):
        return False, f"Invalid characters. Allowed: {rules['allowed_chars']}."

    return True, "Valid plate format."
