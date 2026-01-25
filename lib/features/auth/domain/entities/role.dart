enum Role {
  brand,
  agency,
  mediaOwner,
  admin;

  String get name {
    switch (this) {
      case Role.brand:
        return 'Brand';
      case Role.agency:
        return 'Agency';
      case Role.mediaOwner:
        return 'Media Owner';
      case Role.admin:
        return 'Admin';
    }
  }
}
