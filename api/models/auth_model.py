#!/usr/bin/env python3
"""
Authentication System Threat Model
Call center agent authentication and authorization flow
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

tm = TM("Call Center Authentication System")
tm.description = "Authentication and authorization flow for call center agents accessing the API"
tm.isOrdered = True

# ============================================================================
# BOUNDARIES (Trust Zones)
# ============================================================================

internet = Boundary("Internet")
internet.description = "Untrusted external network"

dmz = Boundary("DMZ")
dmz.description = "Demilitarized zone for public-facing services"

internal = Boundary("Internal Network")
internal.description = "Trusted internal corporate network"

# ============================================================================
# ACTORS (External Entities)
# ============================================================================

agent = Actor("Call Center Agent")
agent.inBoundary = internet
agent.description = "Employee accessing the call center API from remote location"

# ============================================================================
# SERVERS (Application Components)
# ============================================================================

web_app = Server("Web Application")
web_app.inBoundary = dmz
web_app.OS = "Linux"
web_app.isHardened = True
web_app.providesAuthentication = True
web_app.providesAuthorization = True
web_app.protocol = "HTTPS"
web_app.port = 443
web_app.description = "Frontend web application serving the call center API"

auth_service = Server("Authentication Service")
auth_service.inBoundary = internal
auth_service.OS = "Linux"
auth_service.isHardened = True
auth_service.implementsAuthenticationScheme = True
auth_service.protocol = "HTTPS"
auth_service.port = 8443
auth_service.description = "Backend microservice handling authentication and session management"

# ============================================================================
# DATASTORES (Databases)
# ============================================================================

user_db = Datastore("User Database")
user_db.inBoundary = internal
user_db.OS = "Linux"
user_db.isSQL = True
user_db.isEncrypted = True
user_db.storesLoggedIn = True
user_db.storesPII = True
user_db.hasWriteAccess = True
user_db.description = "PostgreSQL database storing user credentials and profile information"

session_cache = Datastore("Session Cache")
session_cache.inBoundary = internal
session_cache.OS = "Linux"
session_cache.isSQL = False
session_cache.isEncrypted = True
session_cache.storesLoggedIn = True
session_cache.description = "Redis cache storing active user sessions"

# ============================================================================
# DATA CLASSIFICATION
# ============================================================================

credentials = Data(
    name="User Credentials",
    classification=Classification.SECRET
)
credentials.isPII = True
credentials.isCredentials = True
credentials.description = "Username and password submitted during login"

session_token = Data(
    name="Session Token",
    classification=Classification.SECRET
)
session_token.isCredentials = True
session_token.description = "JWT token used for authenticated requests"

user_profile = Data(
    name="User Profile",
    classification=Classification.RESTRICTED
)
user_profile.isPII = True
user_profile.description = "Agent profile information including name, role, and permissions"

# ============================================================================
# DATAFLOWS (Connections and Interactions)
# ============================================================================

# Flow 1: Agent submits login credentials
login_request = Dataflow(
    source=agent,
    sink=web_app,
    name="Login Request"
)
login_request.protocol = "HTTPS"
login_request.dstPort = 443
login_request.data = credentials
login_request.isEncrypted = True
login_request.order = 1
login_request.note = "Agent submits username and password via login form"

# Flow 2: Web app forwards credentials to auth service
auth_request = Dataflow(
    source=web_app,
    sink=auth_service,
    name="Verify Credentials"
)
auth_request.protocol = "HTTPS"
auth_request.dstPort = 8443
auth_request.data = credentials
auth_request.isEncrypted = True
auth_request.order = 2
auth_request.note = "Web application forwards credentials to authentication service for verification"

# Flow 3: Auth service queries user database
db_query = Dataflow(
    source=auth_service,
    sink=user_db,
    name="Query User"
)
db_query.protocol = "PostgreSQL"
db_query.dstPort = 5432
db_query.data = credentials
db_query.isEncrypted = True
db_query.order = 3
db_query.note = "Authentication service checks credentials against stored password hash"

# Flow 4: Database returns user data
db_response = Dataflow(
    source=user_db,
    sink=auth_service,
    name="User Data"
)
db_response.protocol = "PostgreSQL"
db_response.dstPort = 5432
db_response.data = user_profile
db_response.isEncrypted = True
db_response.order = 4
db_response.note = "Database returns user profile if credentials are valid"

# Flow 5: Auth service creates session
create_session = Dataflow(
    source=auth_service,
    sink=session_cache,
    name="Store Session"
)
create_session.protocol = "Redis"
create_session.dstPort = 6379
create_session.data = session_token
create_session.isEncrypted = True
create_session.order = 5
create_session.note = "Authentication service creates and stores active session in cache"

# Flow 6: Auth service returns token to web app
return_token = Dataflow(
    source=auth_service,
    sink=web_app,
    name="Session Token"
)
return_token.protocol = "HTTPS"
return_token.dstPort = 8443
return_token.data = session_token
return_token.isEncrypted = True
return_token.order = 6
return_token.note = "Authentication service returns JWT token to web application"

# Flow 7: Web app sends token to agent
login_response = Dataflow(
    source=web_app,
    sink=agent,
    name="Login Success"
)
login_response.protocol = "HTTPS"
login_response.dstPort = 443
login_response.data = session_token
login_response.isEncrypted = True
login_response.order = 7
login_response.note = "Agent receives session token stored in secure HTTP-only cookie"

# ============================================================================
# PROCESS MODEL
# ============================================================================

if __name__ == "__main__":
    tm.process()