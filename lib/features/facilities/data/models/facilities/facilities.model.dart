import 'package:equatable/equatable.dart';

import 'address.model.dart';

class FacilitiesModel extends Equatable {
	final int? id;
	final String? name;
	final String? openingTime;
	final String? closingTime;
	final String? imageUrl;
	final int? ownerId;
	final Address? address;

	const FacilitiesModel({
		this.id, 
		this.name, 
		this.openingTime, 
		this.closingTime, 
		this.imageUrl, 
		this.ownerId, 
		this.address, 
	});

	factory FacilitiesModel.fromJson(Map<String, dynamic> json) => FacilitiesModel(
				id: json['id'] as int?,
				name: json['name'] as String?,
				openingTime: json['openingTime'] as String?,
				closingTime: json['closingTime'] as String?,
				imageUrl: json['imageUrl'] as String?,
				ownerId: json['ownerId'] as int?,
				address: json['address'] == null
						? null
						: Address.fromJson(json['address'] as Map<String, dynamic>),
			);

	Map<String, dynamic> toJson() => {
				'id': id,
				'name': name,
				'openingTime': openingTime,
				'closingTime': closingTime,
				'imageUrl': imageUrl,
				'ownerId': ownerId,
				'address': address?.toJson(),
			};

	@override
	List<Object?> get props {
		return [
				id,
				name,
				openingTime,
				closingTime,
				imageUrl,
				ownerId,
				address,
		];
	}
}
