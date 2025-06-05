# ide_integration.py
"""
Integration layer for popular IDEs
"""


class CursorIntegration:
    """Integration with Cursor IDE"""

    def __init__(self):
        self.proxy = LLMProxyServer()

    def intercept_claude_request(self, prompt: str) -> str:
        """Intercept Cursor's Claude requests"""
        result = self.proxy.handle_ide_request(prompt)
        return result["final_result"]


class WindsurfIntegration:
    """Integration with Windsurf IDE"""

    def __init__(self):
        self.proxy = LLMProxyServer()

    def process_llm_request(self, request_data: Dict) -> Dict:
        """Process Windsurf LLM requests"""
        prompt = request_data.get("prompt", "")
        result = self.proxy.handle_ide_request(prompt)

        return {
            "response": result["final_result"],
            "safety_validated": result["safety_score"] > 0.8,
            "attempts": len(result["attempts"])
        }