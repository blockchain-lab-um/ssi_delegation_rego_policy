package delegation

default allow := false

allow if {
  input.credentialSubject.delegatee == input.holder
  valid_grant_and_role
  valid_constraints
}

valid_grant_and_role if {
  "pick_up_package" in input.credentialSubject.grants
  some r in input.credentialSubject.roles
  r in allowed_roles_for_package
}

valid_grant_and_role if {
  "pick_up_registered_mail" in input.credentialSubject.grants
  "spouse" in input.credentialSubject.roles
  input.credentialSubject.constraint.registeredMailTrackingId
  has_marriage_credential
}

allowed_roles_for_package := ["friend", "neighbor", "family"]

has_marriage_credential if {
  input.supportingCredentials
  some sc in input.supportingCredentials
  "VerifiableCredential" in sc.type
  "MarriageCredential" in sc.type
}

valid_constraints if {
  startswith(input.credentialSubject.constraint.location, "PostOffice_SI_")
  valid_date_window
}

valid_date_window if {
  not missing_date_fields
  input.credentialSubject.constraint.validFrom <= input.currentDate
  input.currentDate <= input.credentialSubject.constraint.validUntil
}

missing_date_fields if {
  not input.credentialSubject.constraint.validFrom
} else if {
  not input.credentialSubject.constraint.validUntil
}
