from fastapi import FastAPI
from semantic_kernel import Kernel
from azure.identity import DefaultAzureCredential
from azure.core.exceptions import ClientAuthenticationError
from semantic_kernel.exceptions.function_exceptions import \
    FunctionExecutionException
from semantic_kernel.connectors.ai.open_ai.services.azure_chat_completion import \
    AzureChatCompletion
from semantic_kernel.contents.chat_history import ChatHistory
from semantic_kernel.functions.kernel_arguments import KernelArguments
from semantic_kernel.connectors.ai.function_choice_behavior import FunctionChoiceBehavior
from semantic_kernel.connectors.ai.open_ai.prompt_execution_settings.azure_chat_prompt_execution_settings import \
    AzureChatPromptExecutionSettings

import dotenv
import os
import logging
import datetime

dotenv.load_dotenv()
app = FastAPI()

azure_openai_endpoint = os.getenv("AZURE_OPENAI_ENDPOINT")
def auth_callback_factory(scope):
    auth_token = None
    async def auth_callback() -> str:
        nonlocal auth_token
        current_utc_timestamp = int(datetime.datetime.now(datetime.timezone.utc).timestamp())

        if not auth_token or auth_token.expires_on < current_utc_timestamp:
            credential = DefaultAzureCredential()

            try:
                auth_token = credential.get_token(scope)
            except ClientAuthenticationError as cae:
                err_messages = getattr(cae, "messages", [])
                raise FunctionExecutionException(
                    f"Failed to retrieve the client auth token with messages: {' '.join(err_messages)}"
                ) from cae

        return auth_token.token
    
    return auth_callback


@app.get("/")
async def root():
    return "Please browse to /chat with a message to chat with the AI."

@app.get("/chat")
async def chat(message: str):
    
    kernel = Kernel()
    
    logging.getLogger().setLevel(logging.DEBUG)
    service_id = "sessions-tool"
    
    chat_service = AzureChatCompletion(
        service_id=service_id,
        ad_token_provider=auth_callback_factory("https://cognitiveservices.azure.com/.default"),
        endpoint=azure_openai_endpoint,
        deployment_name="gpt-4",
    )
    kernel.add_service(chat_service)
    
    chat_function = kernel.add_function(
        prompt="{{$chat_history}}{{$user_input}}",
        plugin_name="ChatBot",
        function_name="Chat",
    )
    # initialize the settings for the Chat service with AzureChatPromptExecutionSettings
    req_settings = AzureChatPromptExecutionSettings(service_id=service_id)
    
    # exclude the ChatBot plugin from the auto function choice
    req_settings.function_choice_behavior = FunctionChoiceBehavior.Auto(filters={"excluded_plugins": ["ChatBot"]})
    
    # Initializing the settings for the request execution.
    arguments = KernelArguments(settings=req_settings)

    history = ChatHistory()
    arguments["chat_history"] = history
    arguments["user_input"] = message
    
    answer = await kernel.invoke(
        function = chat_function,
        arguments=arguments,
    )
    
    response = {
        "output": str(answer)
    }

    return response

