import json
import os

from google import genai

from services.validator import validate_plate

client = genai.Client(api_key=os.getenv("GEMINI_API_KEY"))

SUGGEST_SYSTEM_PROMPT = """You are a creative vanity license plate generator.
Rules for {state} plates:
- Maximum {max_length} characters
- Only letters A-Z, digits 0-9, and spaces
- Total length including spaces must be {max_length} or fewer

Generate clever vanity plate ideas using:
- Abbreviations and shorthand
- Number-letter substitutions (4=FOR, 8=ATE, 2=TO/TOO, 1=ONE/I, 3=E, 0=O)
- Creative wordplay and phonetic spelling
- References to the user's stated interest

Return ONLY a JSON array of uppercase strings. No explanation, no markdown, no code fences.
Example: ["GODAWGS","UGA4EVR","DAWGN8N"]"""

CHAT_SYSTEM_PROMPT = """You are a creative vanity license plate assistant helping a user find the perfect plate.
Rules for {state} plates:
- Maximum {max_length} characters
- Only letters A-Z, digits 0-9, and spaces
- Total length including spaces must be {max_length} or fewer

The user's area of interest is: {interest}

Respond conversationally but always include new plate suggestions.
At the end of your response, include a JSON array of your new suggestions on its own line,
prefixed with "SUGGESTIONS:" — e.g., SUGGESTIONS: ["PLATE1","PLATE2"]"""


async def generate_suggestions(interest: str, state: str = "GA") -> list[str]:
    rules = {"state": state, "max_length": 7}
    system = SUGGEST_SYSTEM_PROMPT.format(**rules)

    response = client.models.generate_content(
        model="gemini-2.5-flash",
        contents=f"Generate 15 vanity plate ideas for someone interested in: {interest}",
        config=genai.types.GenerateContentConfig(
            system_instruction=system,
            max_output_tokens=4096,
            temperature=0.9,
        ),
    )

    raw = response.text.strip()

    # Strip markdown code fences if present
    if raw.startswith("```"):
        raw = raw.split("\n", 1)[1] if "\n" in raw else raw[3:]
        if raw.endswith("```"):
            raw = raw[:-3]
        raw = raw.strip()

    try:
        plates = json.loads(raw)
    except json.JSONDecodeError:
        # Try to extract JSON array from response
        start = raw.find("[")
        end = raw.rfind("]") + 1
        if start >= 0 and end > start:
            plates = json.loads(raw[start:end])
        else:
            return []

    # Filter to only valid plates
    return [p.upper() for p in plates if validate_plate(p, state)[0]]


async def chat_refine(
    interest: str, message: str, history: list[dict], state: str = "GA"
) -> tuple[list[str], str]:
    rules = {"state": state, "max_length": 7, "interest": interest}
    system = CHAT_SYSTEM_PROMPT.format(**rules)

    # Build Gemini conversation format
    contents = []
    for msg in history:
        role = "user" if msg["role"] == "user" else "model"
        contents.append(genai.types.Content(role=role, parts=[genai.types.Part(text=msg["content"])]))
    contents.append(genai.types.Content(role="user", parts=[genai.types.Part(text=message)]))

    response = client.models.generate_content(
        model="gemini-2.5-flash",
        contents=contents,
        config=genai.types.GenerateContentConfig(
            system_instruction=system,
            max_output_tokens=4096,
            temperature=0.9,
        ),
    )

    reply = response.text.strip()

    # Extract suggestions from the SUGGESTIONS: line
    suggestions = []
    lines = reply.split("\n")
    clean_lines = []
    for line in lines:
        if line.strip().startswith("SUGGESTIONS:"):
            json_part = line.split("SUGGESTIONS:", 1)[1].strip()
            try:
                suggestions = json.loads(json_part)
                suggestions = [p.upper() for p in suggestions if validate_plate(p, state)[0]]
            except json.JSONDecodeError:
                pass
        else:
            clean_lines.append(line)

    return suggestions, "\n".join(clean_lines).strip()
