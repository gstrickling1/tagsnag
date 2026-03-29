"""Georgia plate availability checking.

The official GA DRIVES eServices (eservices.drives.ga.gov) has a Prestige Tag
Inquiry tool, but it's protected by hCaptcha. We can't automate it directly.

Strategy:
- Provide a direct link to the official checker for users
- Return "unknown" status with a helpful message and the direct link
- The app's primary value is AI-powered plate name generation + validation
"""

# Direct link to the official GA DRIVES Prestige Tag Inquiry
GA_DRIVES_PRESTIGE_URL = "https://eservices.drives.ga.gov/?Link=Prestige"


async def check_plate_ga(plate: str) -> str:
    """Check if a GA prestige plate is available.

    Currently returns 'unknown' because the official GA DRIVES site
    requires hCaptcha. The app provides a direct link for manual checking.

    Returns: "not_found", "assigned", or "unknown"
    """
    return "unknown"


def get_official_check_url() -> str:
    """Get the URL for the official GA plate availability checker."""
    return GA_DRIVES_PRESTIGE_URL
