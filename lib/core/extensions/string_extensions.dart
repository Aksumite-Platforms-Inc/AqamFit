extension StringCapitalizeExtension on String {
  String capitalize() {
    if (this.isEmpty) {
      return this;
    }
    if (this.length == 1) {
      return this.toUpperCase();
    }
    return this[0].toUpperCase() + this.substring(1).toLowerCase();
  }
}
