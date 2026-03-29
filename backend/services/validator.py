import re

# State-specific vanity plate rules
# Most states allow 2-7 characters. Rules vary by state.
STATE_RULES = {
    "AL": {"max_length": 5, "pattern": r"^[A-Z0-9 ]{1,5}$", "allowed_chars": "A-Z, 0-9, and spaces", "notes": "Alabama: up to 5 characters."},
    "AK": {"max_length": 6, "pattern": r"^[A-Z0-9 ]{1,6}$", "allowed_chars": "A-Z, 0-9, and spaces", "notes": "Alaska: up to 6 characters."},
    "AZ": {"max_length": 7, "pattern": r"^[A-Z0-9 ]{1,7}$", "allowed_chars": "A-Z, 0-9, and spaces", "notes": "Arizona: up to 7 characters."},
    "AR": {"max_length": 7, "pattern": r"^[A-Z0-9 ]{1,7}$", "allowed_chars": "A-Z, 0-9, and spaces", "notes": "Arkansas: up to 7 characters."},
    "CA": {"max_length": 7, "pattern": r"^[A-Z0-9 ]{2,7}$", "allowed_chars": "A-Z, 0-9, and spaces", "notes": "California: 2-7 characters."},
    "CO": {"max_length": 7, "pattern": r"^[A-Z0-9 ]{1,7}$", "allowed_chars": "A-Z, 0-9, and spaces", "notes": "Colorado: up to 7 characters."},
    "CT": {"max_length": 7, "pattern": r"^[A-Z0-9 ]{1,7}$", "allowed_chars": "A-Z, 0-9, and spaces", "notes": "Connecticut: up to 7 characters."},
    "DE": {"max_length": 6, "pattern": r"^[A-Z0-9 ]{1,6}$", "allowed_chars": "A-Z, 0-9, and spaces", "notes": "Delaware: up to 6 characters."},
    "FL": {"max_length": 7, "pattern": r"^[A-Z0-9 ]{1,7}$", "allowed_chars": "A-Z, 0-9, and spaces", "notes": "Florida: up to 7 characters."},
    "GA": {"max_length": 7, "pattern": r"^[A-Z0-9 ]{1,7}$", "allowed_chars": "A-Z, 0-9, and spaces", "notes": "Georgia: up to 7 characters."},
    "HI": {"max_length": 6, "pattern": r"^[A-Z0-9 ]{1,6}$", "allowed_chars": "A-Z, 0-9, and spaces", "notes": "Hawaii: up to 6 characters."},
    "ID": {"max_length": 7, "pattern": r"^[A-Z0-9 ]{1,7}$", "allowed_chars": "A-Z, 0-9, and spaces", "notes": "Idaho: up to 7 characters."},
    "IL": {"max_length": 7, "pattern": r"^[A-Z0-9 ]{1,7}$", "allowed_chars": "A-Z, 0-9, and spaces", "notes": "Illinois: up to 7 characters."},
    "IN": {"max_length": 7, "pattern": r"^[A-Z0-9 ]{1,7}$", "allowed_chars": "A-Z, 0-9, and spaces", "notes": "Indiana: up to 7 characters."},
    "IA": {"max_length": 7, "pattern": r"^[A-Z0-9 ]{1,7}$", "allowed_chars": "A-Z, 0-9, and spaces", "notes": "Iowa: up to 7 characters."},
    "KS": {"max_length": 7, "pattern": r"^[A-Z0-9 ]{1,7}$", "allowed_chars": "A-Z, 0-9, and spaces", "notes": "Kansas: up to 7 characters."},
    "KY": {"max_length": 7, "pattern": r"^[A-Z0-9 ]{1,7}$", "allowed_chars": "A-Z, 0-9, and spaces", "notes": "Kentucky: up to 7 characters."},
    "LA": {"max_length": 7, "pattern": r"^[A-Z0-9 ]{1,7}$", "allowed_chars": "A-Z, 0-9, and spaces", "notes": "Louisiana: up to 7 characters."},
    "ME": {"max_length": 7, "pattern": r"^[A-Z0-9 ]{1,7}$", "allowed_chars": "A-Z, 0-9, and spaces", "notes": "Maine: up to 7 characters."},
    "MD": {"max_length": 7, "pattern": r"^[A-Z0-9 ]{1,7}$", "allowed_chars": "A-Z, 0-9, and spaces", "notes": "Maryland: up to 7 characters."},
    "MA": {"max_length": 6, "pattern": r"^[A-Z0-9 ]{1,6}$", "allowed_chars": "A-Z, 0-9, and spaces", "notes": "Massachusetts: up to 6 characters."},
    "MI": {"max_length": 7, "pattern": r"^[A-Z0-9 ]{1,7}$", "allowed_chars": "A-Z, 0-9, and spaces", "notes": "Michigan: up to 7 characters."},
    "MN": {"max_length": 7, "pattern": r"^[A-Z0-9 ]{1,7}$", "allowed_chars": "A-Z, 0-9, and spaces", "notes": "Minnesota: up to 7 characters."},
    "MS": {"max_length": 7, "pattern": r"^[A-Z0-9 ]{1,7}$", "allowed_chars": "A-Z, 0-9, and spaces", "notes": "Mississippi: up to 7 characters."},
    "MO": {"max_length": 6, "pattern": r"^[A-Z0-9 ]{1,6}$", "allowed_chars": "A-Z, 0-9, and spaces", "notes": "Missouri: up to 6 characters."},
    "MT": {"max_length": 7, "pattern": r"^[A-Z0-9 ]{1,7}$", "allowed_chars": "A-Z, 0-9, and spaces", "notes": "Montana: up to 7 characters."},
    "NE": {"max_length": 7, "pattern": r"^[A-Z0-9 ]{1,7}$", "allowed_chars": "A-Z, 0-9, and spaces", "notes": "Nebraska: up to 7 characters."},
    "NV": {"max_length": 7, "pattern": r"^[A-Z0-9 ]{1,7}$", "allowed_chars": "A-Z, 0-9, and spaces", "notes": "Nevada: up to 7 characters."},
    "NH": {"max_length": 7, "pattern": r"^[A-Z0-9 ]{1,7}$", "allowed_chars": "A-Z, 0-9, and spaces", "notes": "New Hampshire: up to 7 characters."},
    "NJ": {"max_length": 7, "pattern": r"^[A-Z0-9 ]{1,7}$", "allowed_chars": "A-Z, 0-9, and spaces", "notes": "New Jersey: up to 7 characters."},
    "NM": {"max_length": 7, "pattern": r"^[A-Z0-9 ]{1,7}$", "allowed_chars": "A-Z, 0-9, and spaces", "notes": "New Mexico: up to 7 characters."},
    "NY": {"max_length": 8, "pattern": r"^[A-Z0-9 ]{1,8}$", "allowed_chars": "A-Z, 0-9, and spaces", "notes": "New York: up to 8 characters."},
    "NC": {"max_length": 7, "pattern": r"^[A-Z0-9 ]{1,7}$", "allowed_chars": "A-Z, 0-9, and spaces", "notes": "North Carolina: up to 7 characters."},
    "ND": {"max_length": 7, "pattern": r"^[A-Z0-9 ]{1,7}$", "allowed_chars": "A-Z, 0-9, and spaces", "notes": "North Dakota: up to 7 characters."},
    "OH": {"max_length": 7, "pattern": r"^[A-Z0-9 ]{1,7}$", "allowed_chars": "A-Z, 0-9, and spaces", "notes": "Ohio: up to 7 characters."},
    "OK": {"max_length": 7, "pattern": r"^[A-Z0-9 ]{1,7}$", "allowed_chars": "A-Z, 0-9, and spaces", "notes": "Oklahoma: up to 7 characters."},
    "OR": {"max_length": 6, "pattern": r"^[A-Z0-9 ]{1,6}$", "allowed_chars": "A-Z, 0-9, and spaces", "notes": "Oregon: up to 6 characters."},
    "PA": {"max_length": 7, "pattern": r"^[A-Z0-9 ]{1,7}$", "allowed_chars": "A-Z, 0-9, and spaces", "notes": "Pennsylvania: up to 7 characters."},
    "RI": {"max_length": 6, "pattern": r"^[A-Z0-9 ]{1,6}$", "allowed_chars": "A-Z, 0-9, and spaces", "notes": "Rhode Island: up to 6 characters."},
    "SC": {"max_length": 7, "pattern": r"^[A-Z0-9 ]{1,7}$", "allowed_chars": "A-Z, 0-9, and spaces", "notes": "South Carolina: up to 7 characters."},
    "SD": {"max_length": 7, "pattern": r"^[A-Z0-9 ]{1,7}$", "allowed_chars": "A-Z, 0-9, and spaces", "notes": "South Dakota: up to 7 characters."},
    "TN": {"max_length": 7, "pattern": r"^[A-Z0-9 ]{1,7}$", "allowed_chars": "A-Z, 0-9, and spaces", "notes": "Tennessee: up to 7 characters."},
    "TX": {"max_length": 7, "pattern": r"^[A-Z0-9 ]{1,7}$", "allowed_chars": "A-Z, 0-9, and spaces", "notes": "Texas: up to 7 characters."},
    "UT": {"max_length": 7, "pattern": r"^[A-Z0-9 ]{1,7}$", "allowed_chars": "A-Z, 0-9, and spaces", "notes": "Utah: up to 7 characters."},
    "VT": {"max_length": 7, "pattern": r"^[A-Z0-9 ]{1,7}$", "allowed_chars": "A-Z, 0-9, and spaces", "notes": "Vermont: up to 7 characters."},
    "VA": {"max_length": 7, "pattern": r"^[A-Z0-9 ]{1,7}$", "allowed_chars": "A-Z, 0-9, and spaces", "notes": "Virginia: up to 7 characters."},
    "WA": {"max_length": 7, "pattern": r"^[A-Z0-9 ]{1,7}$", "allowed_chars": "A-Z, 0-9, and spaces", "notes": "Washington: up to 7 characters."},
    "WV": {"max_length": 7, "pattern": r"^[A-Z0-9 ]{1,7}$", "allowed_chars": "A-Z, 0-9, and spaces", "notes": "West Virginia: up to 7 characters."},
    "WI": {"max_length": 7, "pattern": r"^[A-Z0-9 ]{1,7}$", "allowed_chars": "A-Z, 0-9, and spaces", "notes": "Wisconsin: up to 7 characters."},
    "WY": {"max_length": 5, "pattern": r"^[A-Z0-9 ]{1,5}$", "allowed_chars": "A-Z, 0-9, and spaces", "notes": "Wyoming: up to 5 characters."},
    "DC": {"max_length": 7, "pattern": r"^[A-Z0-9 ]{1,7}$", "allowed_chars": "A-Z, 0-9, and spaces", "notes": "District of Columbia: up to 7 characters."},
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

    if not re.match(rules["pattern"], plate_upper):
        return False, f"Invalid characters. Allowed: {rules['allowed_chars']}."

    return True, "Valid plate format."
