#!/usr/bin/env python3
"""
Communications System Threat Model
Voice and chat communication flows between customers and agents
"""

from pytm import (
    TM,
    Server,
    Datastore,
    Dataflow,
    Boundary,
    Actor,
    Data,
    Classification
)

# ============================================================================
# THREAT MODEL DEFINITION
# ============================================================================

tm = TM("Call Center Communications System")
tm.description = "Voice and chat communication channels between customers and call center agents"
tm.isOrdered = True

# ============================================================================
# BOUNDARIES (Trust Zones)
# ============================================================================

internet = Boundary("Internet")
internet.description = "Public internet where customers connect from"

dmz = Boundary("DMZ")
dmz.description = "Demilitarized zone with communication gateways"

internal = Boundary("Internal Network")
internal.description = "Internal network with agent workstations and logging systems"

# ============================================================================
# ACTORS (External Entities)
# ============================================================================

customer = Actor("Customer")
customer.inBoundary = internet
customer.description = "Customer calling or chatting for support"

agent = Actor("Call Center Agent")
agent.inBoundary = internal
agent.description = "Agent handling customer communications"

# ============================================================================
# SERVERS (Communication Components)
# ============================================================================

voip_gateway = Server("VoIP Gateway")
voip_gateway.inBoundary = dmz
voip_gateway.OS = "Linux"
voip_gateway.isHardened = True
voip_gateway.protocol = "SIP"
voip_gateway.port = 5060
voip_gateway.description = "SIP gateway handling incoming voice calls"

chat_server = Server("Chat Server")
chat_server.inBoundary = dmz
chat_server.OS = "Linux"
chat_server.isHardened = True
chat_server.providesEncryption = True
chat_server.protocol = "WebSocket"
chat_server.port = 443
chat_server.description = "WebSocket server managing real-time chat sessions"

recording_service = Server("Recording Service")
recording_service.inBoundary = internal
recording_service.OS = "Linux"
recording_service.description = "Service for recording and processing conversations"

# ============================================================================
# DATASTORES (Storage Systems)
# ============================================================================

conversation_log = Datastore("Conversation Log")
conversation_log.inBoundary = internal
conversation_log.OS = "Linux"
conversation_log.isSQL = True
conversation_log.isEncrypted = True
conversation_log.storesPII = True
conversation_log.hasWriteAccess = True
conversation_log.description = "Database storing conversation transcripts and metadata"

recording_storage = Datastore("Recording Storage")
recording_storage.inBoundary = internal
recording_storage.OS = "Linux"
recording_storage.isSQL = False
recording_storage.isEncrypted = True
recording_storage.storesPII = True
recording_storage.description = "Object storage for audio recordings"

# ============================================================================
# DATA CLASSIFICATION
# ============================================================================

voice_data = Data(
    name="Voice Stream",
    classification=Classification.RESTRICTED
)
voice_data.isPII = True
voice_data.description = "Real-time audio stream from customer call"

chat_message = Data(
    name="Chat Message",
    classification=Classification.RESTRICTED
)
chat_message.isPII = True
chat_message.description = "Text messages exchanged in chat session"

conversation_metadata = Data(
    name="Conversation Metadata",
    classification=Classification.RESTRICTED
)
conversation_metadata.isPII = True
conversation_metadata.description = "Call duration, timestamps, participant IDs"

# ============================================================================
# DATAFLOWS - VOICE CALL PATH
# ============================================================================

# Flow 1: Customer initiates voice call
incoming_call = Dataflow(
    source=customer,
    sink=voip_gateway,
    name="Incoming Call"
)
incoming_call.protocol = "SIP/RTP"
incoming_call.dstPort = 5060
incoming_call.data = voice_data
incoming_call.isEncrypted = True
incoming_call.order = 1
incoming_call.note = "Customer initiates voice call through VoIP gateway"

# Flow 2: Gateway routes call to agent
route_to_agent = Dataflow(
    source=voip_gateway,
    sink=agent,
    name="Route Call"
)
route_to_agent.protocol = "RTP"
route_to_agent.data = voice_data
route_to_agent.isEncrypted = True
route_to_agent.order = 2
route_to_agent.note = "Gateway routes call to available agent"

# Flow 3: Voice call to recording service
record_voice = Dataflow(
    source=voip_gateway,
    sink=recording_service,
    name="Record Call"
)
record_voice.protocol = "RTP"
record_voice.data = voice_data
record_voice.isEncrypted = True
record_voice.order = 3
record_voice.note = "Voice stream copied to recording service"

# Flow 4: Store voice recording
store_recording = Dataflow(
    source=recording_service,
    sink=recording_storage,
    name="Store Recording"
)
store_recording.protocol = "S3"
store_recording.data = voice_data
store_recording.isEncrypted = True
store_recording.order = 4
store_recording.note = "Encrypted audio file stored in object storage"

# ============================================================================
# DATAFLOWS - CHAT PATH
# ============================================================================

# Flow 5: Customer sends chat message
chat_message_in = Dataflow(
    source=customer,
    sink=chat_server,
    name="Chat Message"
)
chat_message_in.protocol = "WebSocket"
chat_message_in.dstPort = 443
chat_message_in.data = chat_message
chat_message_in.isEncrypted = True
chat_message_in.order = 5
chat_message_in.note = "Customer sends message via WebSocket connection"

# Flow 6: Deliver message to agent
deliver_to_agent = Dataflow(
    source=chat_server,
    sink=agent,
    name="Deliver Message"
)
deliver_to_agent.protocol = "WebSocket"
deliver_to_agent.data = chat_message
deliver_to_agent.isEncrypted = True
deliver_to_agent.order = 6
deliver_to_agent.note = "Message delivered to agent's API"

# Flow 7: Agent responds
agent_response = Dataflow(
    source=agent,
    sink=chat_server,
    name="Agent Response"
)
agent_response.protocol = "WebSocket"
agent_response.data = chat_message
agent_response.isEncrypted = True
agent_response.order = 7
agent_response.note = "Agent sends response message"

# Flow 8: Deliver response to customer
deliver_to_customer = Dataflow(
    source=chat_server,
    sink=customer,
    name="Response Delivery"
)
deliver_to_customer.protocol = "WebSocket"
deliver_to_customer.data = chat_message
deliver_to_customer.isEncrypted = True
deliver_to_customer.order = 8
deliver_to_customer.note = "Response delivered to customer"

# ============================================================================
# DATAFLOWS - LOGGING
# ============================================================================

# Flow 9: Log voice call metadata
log_voice_metadata = Dataflow(
    source=voip_gateway,
    sink=conversation_log,
    name="Log Call Metadata"
)
log_voice_metadata.protocol = "PostgreSQL"
log_voice_metadata.dstPort = 5432
log_voice_metadata.data = conversation_metadata
log_voice_metadata.isEncrypted = True
log_voice_metadata.order = 9
log_voice_metadata.note = "Call metadata logged to database"

# Flow 10: Log chat conversation
log_chat = Dataflow(
    source=chat_server,
    sink=conversation_log,
    name="Log Chat"
)
log_chat.protocol = "PostgreSQL"
log_chat.dstPort = 5432
log_chat.data = chat_message
log_chat.isEncrypted = True
log_chat.order = 10
log_chat.note = "Chat messages stored in conversation log"

# ============================================================================
# PROCESS MODEL
# ============================================================================

if __name__ == "__main__":
    tm.process()