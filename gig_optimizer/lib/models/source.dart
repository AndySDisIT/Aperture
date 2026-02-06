class Source {
  const Source({
    required this.id,
    required this.name,
    required this.category,
    required this.typicalDurationMinutes,
    required this.proofRequirements,
    required this.reliabilityScore,
  });

  final String id;
  final String name;
  final String category;
  final int typicalDurationMinutes;
  final String proofRequirements;
  final double reliabilityScore;

  factory Source.fromJson(Map<String, dynamic> json) {
    return Source(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      typicalDurationMinutes: json['typical_duration_minutes'] as int,
      proofRequirements: json['proof_requirements'] as String,
      reliabilityScore: (json['reliability_score'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'typical_duration_minutes': typicalDurationMinutes,
      'proof_requirements': proofRequirements,
      'reliability_score': reliabilityScore,
    };
  }
}
