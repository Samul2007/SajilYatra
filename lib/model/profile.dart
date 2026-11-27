enum VerificationStatus {
  notSubmitted('Not submitted'),
  pending('Pending'),
  verified('Verified'),
  rejected('Rejected');

  const VerificationStatus(this.label);
  final String label;
}

/// The four profile types, in the order they are shown.
const profileRoles = [
  'Commuter',
  'Student',
  'Senior Citizen',
  'Conductor / Driver',
];

/// These profiles must upload an ID photo; Commuter needs none.
const rolesNeedingId = {'Student', 'Senior Citizen', 'Conductor / Driver'};
