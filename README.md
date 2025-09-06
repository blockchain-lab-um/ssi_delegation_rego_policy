# Postal Delegation Policy (Rego / OPA)

This repository contains a Rego policy for verifying whether a delegatee may pick up:

- a **standard package**, or  
- **registered mail** (requires spouse role + marriage credential),

subject to **location** and **date window** constraints.

---

## Repository Structure

```
.
├── policy/
│   └── delegation.rego
├── inputs/
│   ├── registered_mail_allow.json
│   ├── registered_mail_no_marriage.json
│   ├── registered_mail_wrong_role.json
│   ├── registered_mail_missing_tracking.json
│   ├── registered_mail_delegatee_mismatch.json
│   ├── registered_mail_expired_date.json
│   ├── registered_mail_location_invalid.json
│   ├── package_allow_neighbor.json
│   ├── package_disallowed_role.json
│   ├── package_date_outside.json
│   ├── package_location_invalid.json
│   └── package_delegatee_mismatch.json
└── scripts/
    └── run_all.sh
└── vc_vp/
    └── example_presentation.json
```

- `policy/delegation.rego`: the Rego policy (OPA v1.0+ syntax).
- `inputs/`: JSON inputs covering **all logical scenarios** (both positive and negative).
- `scripts/run_all.sh`: helper script to evaluate all inputs in batch.
- `vc_vp/example_presentation.json`: an example **Verifiable Presentation (VP)** that holds both a **Verifiable Mandate (VM)** and a **MarriageCredential**. This VP illustrates how raw SSI data can be transformed into the input JSONs consumed by the policy.  

---

## Policy Overview

- **Decision entrypoint**: `data.delegation.allow`
- **Package pickup** is allowed if:
  - `grant = "pick_up_package"`
  - Role is one of `["friend", "neighbor", "family"]`
  - Delegatee matches the holder
  - Location starts with `PostOffice_SI_`
  - Current date is within `validFrom` and `validUntil`

- **Registered mail pickup** is allowed if:
  - `grant = "pick_up_registered_mail"`
  - Role is `"spouse"`
  - `registeredMailTrackingId` is present
  - A supporting credential includes both `"VerifiableCredential"` and `"MarriageCredential"`
  - Delegatee matches the holder
  - Location starts with `PostOffice_SI_`
  - Current date is within the date window

---

## Quick Start

### 1. Install OPA

Follow instructions at [OPA documentation](https://www.openpolicyagent.org/docs/latest/#running-opa).

### 2. Evaluate a single case

```bash
opa eval -d policy/delegation.rego -i inputs/registered_mail_allow.json 'data.delegation'
# or just the boolean decision:
opa eval -d policy/delegation.rego -i inputs/registered_mail_allow.json 'data.delegation.allow'
```

### 3. Run all fixtures

Use the helper script to test every input:

```bash
bash scripts/run_all.sh
```

Expected results:

| Input file                                | Expected `allow` |
|-------------------------------------------|------------------|
| registered_mail_allow.json                | true             |
| registered_mail_no_marriage.json          | false            |
| registered_mail_wrong_role.json           | false            |
| registered_mail_missing_tracking.json     | false            |
| registered_mail_delegatee_mismatch.json   | false            |
| registered_mail_expired_date.json         | false            |
| registered_mail_location_invalid.json     | false            |
| package_allow_neighbor.json               | true             |
| package_disallowed_role.json              | false            |
| package_date_outside.json                 | false            |
| package_location_invalid.json             | false            |
| package_delegatee_mismatch.json           | false            |

---

## Development Notes

- Policy uses idiomatic constructs: `:=` assignment, `in` membership, `some … in` iteration, and `if` syntax.
- Dates are ISO-8601 (`YYYY-MM-DD`) and compare correctly as strings.
- Run `opa fmt -w policy/delegation.rego` to auto-format.

---
