"""
LLM Client for Ollama Integration
Provides RAG-style product information queries
"""
import os
import json
import requests
from typing import Dict, Optional, Any
from loguru import logger

# Configuration
LLM_URL = os.getenv("LLM_URL", "http://localhost:11434")
LLM_MODEL = os.getenv("LLM_MODEL", "phi3")  # Microsoft Phi-3 - optimized for edge/CPU
LLM_TIMEOUT = int(os.getenv("LLM_TIMEOUT", "30"))  # seconds


class LLMClient:
    """Client for interacting with Ollama LLM service"""
    
    def __init__(self, base_url: str = LLM_URL, model: str = LLM_MODEL):
        self.base_url = base_url.rstrip('/')
        self.model = model
        self.generate_url = f"{self.base_url}/api/generate"
        self.chat_url = f"{self.base_url}/api/chat"
        
    def is_available(self) -> bool:
        """Check if LLM service is available"""
        try:
            response = requests.get(f"{self.base_url}/api/tags", timeout=5)
            return response.status_code == 200
        except Exception as e:
            logger.warning(f"LLM service not available: {e}")
            return False
    
    def consultar_llm(
        self, 
        product_info: Dict[str, Any], 
        user_question: Optional[str] = None,
        context: Optional[str] = None
    ) -> str:
        """
        Query LLM with product information using RAG approach
        
        Args:
            product_info: Dictionary with product data (name, description, price, stock, etc.)
            user_question: Optional specific question from user
            context: Optional additional context
            
        Returns:
            str: LLM response in natural language
        """
        try:
            # Build RAG-style prompt
            prompt = self._build_prompt(product_info, user_question, context)
            
            logger.info(f"🧠 Querying LLM with model: {self.model}")
            logger.debug(f"Prompt: {prompt[:200]}...")
            
            # Call Ollama API
            payload = {
                "model": self.model,
                "prompt": prompt,
                "stream": False,
                "options": {
                    "temperature": 0.7,
                    "top_p": 0.9,
                    "max_tokens": 300
                }
            }
            
            response = requests.post(
                self.generate_url,
                json=payload,
                timeout=LLM_TIMEOUT
            )
            
            if response.status_code != 200:
                logger.error(f"LLM API error: {response.status_code} - {response.text}")
                return self._fallback_response(product_info)
            
            result = response.json()
            llm_response = result.get("response", "").strip()
            
            if not llm_response:
                logger.warning("Empty LLM response, using fallback")
                return self._fallback_response(product_info)
            
            logger.success(f"✅ LLM response received ({len(llm_response)} chars)")
            return llm_response
            
        except requests.exceptions.Timeout:
            logger.error("LLM request timeout")
            return self._fallback_response(product_info)
        except Exception as e:
            logger.error(f"Error querying LLM: {e}")
            return self._fallback_response(product_info)
    
    def _build_prompt(
        self, 
        product_info: Dict[str, Any], 
        user_question: Optional[str],
        context: Optional[str]
    ) -> str:
        """Build RAG-style prompt with product information"""
        
        # Extract product details
        name = product_info.get('name', 'Unknown Product')
        description = product_info.get('description', 'No description available')
        category = product_info.get('category', 'Unknown')
        price = product_info.get('price', 0)
        stock = product_info.get('stock', 0)
        manufacturer = product_info.get('manufacturer', 'Unknown')
        barcode = product_info.get('barcode', 'N/A')
        
        # Build structured prompt
        prompt = f"""Actua com un assistent intel·ligent d'un sistema de gestió d'inventari.

INFORMACIÓ DEL PRODUCTE:
- Nom: {name}
- Descripció: {description}
- Categoria: {category}
- Preu: {price}€
- Stock disponible: {stock} unitats
- Fabricant: {manufacturer}
- Codi de barres: {barcode}
"""
        
        if context:
            prompt += f"\nCONTEXT ADDICIONAL:\n{context}\n"
        
        if user_question:
            prompt += f"\nPREGUNTA DE L'USUARI:\n{user_question}\n"
        else:
            prompt += "\nTASCA:\nProporciona un resum informatiu i útil sobre aquest producte."
        
        prompt += """
INSTRUCCIONS:
- Respon en català de forma clara i concisa
- Utilitza la informació proporcionada
- Si el stock és baix (<50), menciona-ho
- Si el preu és rellevant per la pregunta, inclou-lo
- Sigues útil i professional
- Màxim 3-4 frases

RESPOSTA:"""
        
        return prompt
    
    def _fallback_response(self, product_info: Dict[str, Any]) -> str:
        """Generate fallback response when LLM is unavailable"""
        name = product_info.get('name', 'Producte')
        price = product_info.get('price', 0)
        stock = product_info.get('stock', 0)
        description = product_info.get('description', '')
        
        response = f"📦 {name}"
        
        if price:
            response += f" - Preu: {price}€"
        
        if stock is not None:
            if stock > 0:
                response += f" | Stock: {stock} unitats disponibles"
            else:
                response += " | ⚠️ Sense stock"
        
        if description:
            # Truncate description to first sentence
            first_sentence = description.split('.')[0] + '.'
            if len(first_sentence) < 150:
                response += f"\n{first_sentence}"
        
        return response
    
    def chat(
        self, 
        messages: list, 
        system_prompt: Optional[str] = None
    ) -> str:
        """
        Chat-style interaction with LLM
        
        Args:
            messages: List of message dicts with 'role' and 'content'
            system_prompt: Optional system prompt
            
        Returns:
            str: LLM response
        """
        try:
            payload = {
                "model": self.model,
                "messages": messages,
                "stream": False
            }
            
            if system_prompt:
                payload["messages"].insert(0, {
                    "role": "system",
                    "content": system_prompt
                })
            
            response = requests.post(
                self.chat_url,
                json=payload,
                timeout=LLM_TIMEOUT
            )
            
            if response.status_code == 200:
                result = response.json()
                return result.get("message", {}).get("content", "")
            else:
                logger.error(f"Chat API error: {response.status_code}")
                return ""
                
        except Exception as e:
            logger.error(f"Error in chat: {e}")
            return ""


# Convenience function for quick queries
def consultar_llm(
    product_info: Dict[str, Any], 
    user_question: Optional[str] = None
) -> str:
    """
    Quick function to query LLM about a product
    
    Args:
        product_info: Product data dictionary
        user_question: Optional user question
        
    Returns:
        str: Natural language response
    """
    client = LLMClient()
    return client.consultar_llm(product_info, user_question)


# Example usage
if __name__ == "__main__":
    # Test with sample product
    sample_product = {
        "barcode": "5901234123457",
        "name": "Coca-Cola 330ml",
        "description": "Beguda refrescant amb gas. Llauna de 330ml.",
        "category": "Begudes",
        "price": 1.50,
        "stock": 150,
        "manufacturer": "The Coca-Cola Company"
    }
    
    client = LLMClient()
    
    if client.is_available():
        print("✅ LLM service is available")
        
        # Test query
        response = client.consultar_llm(
            sample_product,
            user_question="Quant costa aquest producte?"
        )
        
        print(f"\n🧠 LLM Response:\n{response}")
    else:
        print("❌ LLM service not available")
        print(f"Fallback: {client._fallback_response(sample_product)}")
