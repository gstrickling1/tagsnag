from scrapers.georgia import check_plate_ga

# Registry of state scrapers
STATE_SCRAPERS = {
    "GA": check_plate_ga,
}


async def check_plate(plate: str, state: str = "GA") -> str:
    """Check plate availability using the appropriate state scraper.

    Returns: "not_found", "assigned", or "unknown"
    """
    scraper = STATE_SCRAPERS.get(state.upper())
    if not scraper:
        return "unknown"
    return await scraper(plate.upper().strip())
