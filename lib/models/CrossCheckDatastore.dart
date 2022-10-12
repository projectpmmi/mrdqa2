class CrossCheckDatastore{
  int primary;
  int secondary;

  CrossCheckDatastore(this.primary, this.secondary);
  Map<String, dynamic> toJson() => {
    "primary": primary,
    "secondary": secondary,
  };
}