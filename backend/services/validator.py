import re

# State-specific vanity plate rules
STATE_RULES = {
    "GA": {
        "max_length": 7,
        "pattern": r"^[A-Z0-9 ]{1,7}$",
        "allowed_chars": "A-Z, 0-9, and spaces",
        "notes": "Georgia vanity plates: 1-7 characters, letters, numbers, and spaces.",
    },
}


def get_rules(state: str) -> dict | None:
    return STATE_RULES.get(state.upper())


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
