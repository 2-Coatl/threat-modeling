#!/usr/bin/env python3
"""
Ticket Management System Threat Model
Support ticket creation, assignment, and resolution workflow
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

tm = TM("Ticket Management System")
tm.description = "Support ticket lifecycle from creation through resolution"
tm.isOrdered = True

# ============================================================================
# BOUNDARIES (Trust Zones)
# ============================================================================

internet = Boundary("Internet")
internal = Boundary("Internal Network")

# ============================================================================
# ACTORS (External Entities)
# ============================================================================

customer = Actor("Customer")
customer.inBoundary = internet
customer.description = "Customer submitting support requests"

agent = Actor("Support Agent")
agent.inBoundary = internal
agent.description = "Agent managing and resolving tickets"

supervisor = Actor("Supervisor")
supervisor.inBoundary = internal
supervisor.description = "Supervisor overseeing ticket resolution"

# ============================================================================
# SERVERS (Application Components)
# ============================================================================

ticket_api = Server("Ticket API")
ticket_api.inBoundary = internal
ticket_api.OS = "Linux"
ticket_api.isHardened = True
ticket_api.providesAuthentication = True
ticket_api.providesAuthorization = True
ticket_api.protocol = "HTTPS"
ticket_api.port = 8443
ticket_api.description = "REST API for ticket operations"

notification_service = Server("Notification Service")
notification_service.inBoundary = internal
notification_service.OS = "Linux"
notification_service.description = "Service for sending email and SMS notifications"

# ============================================================================
# DATASTORES (Storage Systems)
# ============================================================================

ticket_db = Datastore("Ticket Database")
ticket_db.inBoundary = internal
ticket_db.OS = "Linux"
ticket_db.isSQL = True
ticket_db.isEncrypted = True
ticket_db.storesPII = True
ticket_db.hasWriteAccess = True
ticket_db.description = "PostgreSQL database storing ticket information"

attachment_storage = Datastore("Attachment Storage")
attachment_storage.inBoundary = internal
attachment_storage.OS = "Linux"
attachment_storage.isSQL = False
attachment_storage.isEncrypted = True
attachment_storage.storesPII = True
attachment_storage.description = "S3-compatible storage for ticket attachments"

# ============================================================================
# DATA CLASSIFICATION
# ============================================================================

ticket_data = Data(
    name="Ticket Information",
    classification=Classification.RESTRICTED
)
ticket_data.isPII = True
ticket_data.description = "Ticket details including customer information and issue description"

attachment_data = Data(
    name="File Attachment",
    classification=Classification.RESTRICTED
)
attachment_data.isPII = True
attachment_data.description = "Files uploaded by customer (screenshots, logs, etc.)"

notification_data = Data(
    name="Notification",
    classification=Classification.PUBLIC
)
notification_data.description = "Email or SMS notification content"

# ============================================================================
# DATAFLOWS - TICKET CREATION
# ============================================================================

# Flow 1: Customer creates ticket
create_ticket = Dataflow(
    source=customer,
    sink=ticket_api,
    name="Create Ticket"
)
create_ticket.protocol = "HTTPS"
create_ticket.dstPort = 8443
create_ticket.data = ticket_data
create_ticket.isEncrypted = True
create_ticket.order = 1
create_ticket.note = "Customer submits new support ticket"

# Flow 2: Store ticket in database
store_ticket = Dataflow(
    source=ticket_api,
    sink=ticket_db,
    name="Store Ticket"
)
store_ticket.protocol = "PostgreSQL"
store_ticket.dstPort = 5432
store_ticket.data = ticket_data
store_ticket.isEncrypted = True
store_ticket.order = 2
store_ticket.note = "Ticket information stored in database"

# Flow 3: Upload attachment
upload_attachment = Dataflow(
    source=customer,
    sink=ticket_api,
    name="Upload Attachment"
)
upload_attachment.protocol = "HTTPS"
upload_attachment.dstPort = 8443
upload_attachment.data = attachment_data
upload_attachment.isEncrypted = True
upload_attachment.order = 3
upload_attachment.note = "Customer uploads supporting files"

# Flow 4: Store attachment
store_attachment = Dataflow(
    source=ticket_api,
    sink=attachment_storage,
    name="Store Attachment"
)
store_attachment.protocol = "S3"
store_attachment.data = attachment_data
store_attachment.isEncrypted = True
store_attachment.order = 4
store_attachment.note = "Attachment stored in encrypted object storage"

# ============================================================================
# DATAFLOWS - TICKET ASSIGNMENT
# ============================================================================

# Flow 5: Notify agent of new ticket
notify_agent = Dataflow(
    source=ticket_api,
    sink=notification_service,
    name="Ticket Assignment"
)
notify_agent.protocol = "HTTPS"
notify_agent.data = notification_data
notify_agent.isEncrypted = True
notify_agent.order = 5
notify_agent.note = "API requests notification for ticket assignment"

# Flow 6: Send notification to agent
send_notification = Dataflow(
    source=notification_service,
    sink=agent,
    name="Email Notification"
)
send_notification.protocol = "SMTP"
send_notification.dstPort = 587
send_notification.data = notification_data
send_notification.isEncrypted = True
send_notification.order = 6
send_notification.note = "Agent receives email about new ticket"

# Flow 7: Agent retrieves ticket
retrieve_ticket = Dataflow(
    source=agent,
    sink=ticket_api,
    name="Get Ticket Details"
)
retrieve_ticket.protocol = "HTTPS"
retrieve_ticket.dstPort = 8443
retrieve_ticket.data = ticket_data
retrieve_ticket.isEncrypted = True
retrieve_ticket.order = 7
retrieve_ticket.note = "Agent requests full ticket information"

# Flow 8: API fetches ticket from database
fetch_ticket = Dataflow(
    source=ticket_api,
    sink=ticket_db,
    name="Query Ticket"
)
fetch_ticket.protocol = "PostgreSQL"
fetch_ticket.dstPort = 5432
fetch_ticket.data = ticket_data
fetch_ticket.isEncrypted = True
fetch_ticket.order = 8
fetch_ticket.note = "API retrieves ticket from database"

# Flow 9: Return ticket to agent
return_ticket = Dataflow(
    source=ticket_api,
    sink=agent,
    name="Ticket Details"
)
return_ticket.protocol = "HTTPS"
return_ticket.data = ticket_data
return_ticket.isEncrypted = True
return_ticket.order = 9
return_ticket.note = "Ticket details displayed to agent"

# ============================================================================
# DATAFLOWS - TICKET RESOLUTION
# ============================================================================

# Flow 10: Agent updates ticket
update_ticket = Dataflow(
    source=agent,
    sink=ticket_api,
    name="Update Ticket"
)
update_ticket.protocol = "HTTPS"
update_ticket.dstPort = 8443
update_ticket.data = ticket_data
update_ticket.isEncrypted = True
update_ticket.order = 10
update_ticket.note = "Agent adds notes and updates status"

# Flow 11: Persist update
persist_update = Dataflow(
    source=ticket_api,
    sink=ticket_db,
    name="Save Update"
)
persist_update.protocol = "PostgreSQL"
persist_update.dstPort = 5432
persist_update.data = ticket_data
persist_update.isEncrypted = True
persist_update.order = 11
persist_update.note = "Changes saved to database"

# Flow 12: Notify customer of resolution
notify_customer = Dataflow(
    source=notification_service,
    sink=customer,
    name="Resolution Notice"
)
notify_customer.protocol = "SMTP"
notify_customer.dstPort = 587
notify_customer.data = notification_data
notify_customer.isEncrypted = True
notify_customer.order = 12
notify_customer.note = "Customer notified of ticket resolution"

# ============================================================================
# PROCESS MODEL
# ============================================================================

if __name__ == "__main__":
    tm.process()