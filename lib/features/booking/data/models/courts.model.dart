import 'package:equatable/equatable.dart';

class CourtsModel extends Equatable {
	final int? id;
	final String? name;
	final int? facilityId;
	final int? sportId;
	final int? capacity;
	final num? pricePerHour;

	const CourtsModel({
		this.id, 
		this.name, 
		this.facilityId, 
		this.sportId, 
		this.capacity, 
		this.pricePerHour, 
	});

	factory CourtsModel.fromJson(Map<String, dynamic> json) => CourtsModel(
				id: json['id'] as int?,
				name: json['name'] as String?,
				facilityId: json['facilityId'] as int?,
				sportId: json['sportId'] as int?,
				capacity: json['capacity'] as int?,
				pricePerHour: json['pricePerHour'] as num?,
			);

	Map<String, dynamic> toJson() => {
				'id': id,
				'name': name,
				'facilityId': facilityId,
				'sportId': sportId,
				'capacity': capacity,
				'pricePerHour': pricePerHour,
			};

	@override
	List<Object?> get props {
		return [
				id,
				name,
				facilityId,
				sportId,
				capacity,
				pricePerHour,
		];
	}
}
