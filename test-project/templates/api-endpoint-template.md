<!--
API ENDPOINT METADATA
--------------------
endpoint_id: [unique-endpoint-identifier]
version: 0.1.0
author: [Your Name]
last_updated: [YYYY-MM-DD]
api_version: [v1|v2|etc]
status: [active|deprecated|beta]
security_level: [public|authenticated|admin]
rate_limited: [yes|no]
-->

# [Endpoint Name]

<!-- 
USAGE INSTRUCTIONS:
1. Replace all placeholder text in [brackets]
2. Complete the metadata section above
3. Delete these usage instructions
4. Fill in all required sections
5. Save with a descriptive filename using kebab-case: endpoint-name.md
-->

## Endpoint Information

**URL**: `[HTTP method] /api/[endpoint-path]/{parameter}`

**Description**: [A clear, concise description of what this endpoint does and what it's used for]

**Required Scope**: `[required-scope]` (if applicable)

## Authentication

[Describe authentication requirements for this endpoint]

```
Authorization: Bearer [token]
```

## Request Parameters

### Path Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | [Description of the parameter] |

### Query Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `filter` | string | No | `all` | [Description of the parameter] |
| `limit` | integer | No | `20` | [Description of the parameter] |

### Request Body

```json
{
  "property1": "string",
  "property2": 123,
  "nested": {
    "property": true
  }
}
```

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `property1` | string | Yes | [Description of the property] |
| `property2` | integer | Yes | [Description of the property] |
| `nested.property` | boolean | No | [Description of the nested property] |

## Responses

### Success Response

**Status Code**: `200 OK`

```json
{
  "id": "abc123",
  "created": "2025-04-01T12:00:00Z",
  "data": {
    "property1": "value1",
    "property2": 42
  }
}
```

| Property | Type | Description |
|----------|------|-------------|
| `id` | string | [Description of the property] |
| `created` | ISO 8601 datetime | [Description of the property] |
| `data.property1` | string | [Description of the property] |
| `data.property2` | integer | [Description of the property] |

### Error Responses

**Status Code**: `400 Bad Request`

```json
{
  "error": "invalid_request",
  "error_description": "The request is missing a required parameter",
  "details": ["property1 is required"]
}
```

**Status Code**: `401 Unauthorized`

```json
{
  "error": "unauthorized",
  "error_description": "Valid authentication credentials are required"
}
```

**Status Code**: `404 Not Found`

```json
{
  "error": "not_found",
  "error_description": "The requested resource was not found"
}
```

## Error Codes

| Code | Description | Resolution |
|------|-------------|------------|
| `invalid_request` | Request is missing required parameters or malformed | Check your request against the documentation |
| `unauthorized` | Authentication is required or token is invalid | Provide valid authentication credentials |
| `not_found` | The requested resource doesn't exist | Verify the identifier exists |

## Rate Limiting

[Details about rate limits for this endpoint]

* Rate limit: [X] requests per [time period]
* When exceeded: 429 Too Many Requests response
* Headers: 
  * `X-RateLimit-Limit`: [X]
  * `X-RateLimit-Remaining`: [number of requests remaining]
  * `X-RateLimit-Reset`: [timestamp when limit resets]

## Examples

### Example Request: [Scenario Description]

```bash
curl -X POST "https://api.example.com/v1/endpoint" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "property1": "example value",
    "property2": 42
  }'
```

### Example Response

```json
{
  "id": "abc123",
  "created": "2025-04-01T12:00:00Z",
  "data": {
    "property1": "example value",
    "property2": 42
  }
}
```

## Testing Guidelines

### Prerequisites
- Valid API token with appropriate permissions
- [Any specific test environment details]

### Validation Tests
1. [Test scenario 1]
2. [Test scenario 2]
3. [Test for specific error cases]

### Integration Testing Notes
[Notes about how to properly test this endpoint in an integration testing scenario]

## Changelog

| Date | API Version | Changes |
|------|-------------|---------|
| [YYYY-MM-DD] | v1 | Initial implementation |
| [YYYY-MM-DD] | v1.1 | Added `new_parameter` |

## Related Endpoints

- [Related Endpoint 1](/api/related-endpoint) - [Brief description]
- [Related Endpoint 2](/api/another-endpoint) - [Brief description]

---

<!-- Endpoint footer with metadata for tracking -->
Last updated: [YYYY-MM-DD] | Endpoint ID: [unique-endpoint-identifier] | Version: 0.1.0

