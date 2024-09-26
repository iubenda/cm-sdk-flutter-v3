enum ATTStatus {
  notDetermined,
  restricted,
  denied,
  authorized,
}

ATTStatus mapATTStatus(int status) {
  switch (status) {
    case 0:
      return ATTStatus.notDetermined;
    case 1:
      return ATTStatus.restricted;
    case 2:
      return ATTStatus.denied;
    case 3:
      return ATTStatus.authorized;
    default:
      throw ArgumentError('Invalid ATT status: $status');
  }
}
