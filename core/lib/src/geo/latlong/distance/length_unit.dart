class LengthUnit {
    final double scaleFactor;
    const LengthUnit(this.scaleFactor);

    static const LengthUnit millimeter = LengthUnit(1000.0);
    static const LengthUnit centimeter = LengthUnit(100.0);
    static const LengthUnit meter = LengthUnit(1.0);
    static const LengthUnit kilometer = LengthUnit(0.001);
    static const LengthUnit mile = LengthUnit(0.0006213712);

    double to(final LengthUnit unit,final num value) {
        if(unit.scaleFactor == scaleFactor) {
            return value;
        }

        // Convert to primary unit.
        final double primaryValue = value / scaleFactor;

        // Convert to destination unit.
        return primaryValue * unit.scaleFactor;
    }
}