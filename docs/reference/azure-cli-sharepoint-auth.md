# Azure CLI ↔ SharePoint / Graph auth from Linux

Azure CLI's default app registration is **not preauthorized** for SharePoint Online or Microsoft Graph `Sites.*` scopes in most tenants. Default tokens cannot reach SharePoint list / item data planes — neither via SharePoint REST nor via Graph.

## The failure modes

| Acquisition | Result | Why |
|---|---|---|
| `az account get-access-token --resource https://<tenant>.sharepoint.com` | Token issued; HTTP 401 invalid_request on any `/_api/web/...` call | Token audience is right but app registration not granted SharePoint API permissions |
| `az account get-access-token --resource https://graph.microsoft.com` | Token issued; HTTP 403 accessDenied on `/sites/{id}/lists/{id}/items` | Token's scopes include directory/user but **no `Sites.*`** |
| `az account get-access-token --scope "https://graph.microsoft.com/Sites.ReadWrite.All"` | `AADSTS65002: Consent ... must be configured via preauthorization` | Azure CLI's first-party app isn't preauthorized for that scope |

Don't bother with: alternate `--resource` values, swapping `odata=verbose` vs `nometadata` headers, or `az rest` (uses the same underlying CLI token).

## The workaround — one-time consent

The user must run interactively, once per tenant (typically as tenant admin):

```bash
az login --scope "https://graph.microsoft.com/Sites.ReadWrite.All"
```

This triggers an admin-consent prompt. After consent, subsequent `az account get-access-token --resource https://graph.microsoft.com` calls return a Graph token carrying `Sites.ReadWrite.All`, and any script using that token (e.g. `_tools/rollback-config-prompt.py` in MicrosoftFlowsApps) works.

## Why Power Automate works without this

Power Automate's `shared_sharepointonline` and `shared_office365` connections hold tokens bound to **different** first-party app registrations that *do* have the right delegated SharePoint / Outlook permissions. Those credentials are encrypted inside Power Automate and not extractable; we cannot reuse them from Linux.

## Implication: proxy flows are the canonical path

For SharePoint list R/W from Linux, prefer an HTTP-triggered proxy flow over direct Graph calls. The proxy uses the pre-authorized Power Automate connection; the Linux script just `curl`s the proxy. See the [proxy-flow-scaffolding](../../skills/proxy-flow-scaffolding/SKILL.md) skill.

Direct Graph is still useful for narrow one-off needs (rollback scripts, ad-hoc admin operations) — for those, ask the user to run the consent step once.

## Tenant scope

Consent state is per-tenant. A user with access to multiple tenants needs to run the `--scope` login once per tenant.

The scope grant lives on the user's account in Azure AD, not on the Azure CLI install — re-installing Azure CLI doesn't reset it; switching machines doesn't reset it.
