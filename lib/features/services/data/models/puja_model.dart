import '../../../../core/constants/api_constants.dart';

class PujaCategory {
  final String id;
  final String name;
  final String slug;
  final String? image;
  final String? description;

  PujaCategory({
    required this.id,
    required this.name,
    required this.slug,
    this.image,
    this.description,
  });

  String get fullImageUrl {
    if (image == null || image!.isEmpty) return '';
    if (image!.startsWith('http')) return image!;
    return '${ApiConstants.imageBaseUrl}/$image';
  }

  factory PujaCategory.fromJson(Map<String, dynamic> json) {
    return PujaCategory(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      image: json['image'],
      description: json['description'],
    );
  }
}

class PujaSubCategory {
  final String id;
  final String categoryId;
  final String name;
  final String slug;
  final String? image;
  final String? description;

  PujaSubCategory({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.slug,
    this.image,
    this.description,
  });

  String get fullImageUrl {
    if (image == null || image!.isEmpty) return '';
    if (image!.startsWith('http')) return image!;
    return '${ApiConstants.imageBaseUrl}/$image';
  }

  factory PujaSubCategory.fromJson(Map<String, dynamic> json) {
    return PujaSubCategory(
      id: json['_id'] ?? '',
      categoryId: json['categoryId'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      image: json['image'],
      description: json['description'],
    );
  }
}

class PujaBenefit {
  final String title;
  final String description;

  PujaBenefit({required this.title, required this.description});

  factory PujaBenefit.fromJson(Map<String, dynamic> json) {
    return PujaBenefit(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

class PujaPackage {
  final String id;
  final String title;
  final double priceInr;
  final double priceUsd;
  final String description;

  PujaPackage({
    required this.id,
    required this.title,
    required this.priceInr,
    required this.priceUsd,
    required this.description,
  });

  factory PujaPackage.fromJson(Map<String, dynamic> json) {
    return PujaPackage(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      priceInr: (json['priceInr'] ?? 0).toDouble(),
      priceUsd: (json['priceUsd'] ?? 0).toDouble(),
      description: json['description'] ?? '',
    );
  }
}

class Puja {
  final String id;
  final String title;
  final String subtitle;
  final String slug;
  final String? image;
  final String startDateTime;
  final int duration;
  final String place;
  final String about;
  final List<PujaBenefit> benefits;
  final List<PujaPackage> packages;
  final String? categoryId;
  final String? subCategoryId;

  Puja({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.slug,
    this.image,
    required this.startDateTime,
    required this.duration,
    required this.place,
    required this.about,
    required this.benefits,
    required this.packages,
    this.categoryId,
    this.subCategoryId,
  });

  String get fullImageUrl {
    if (image == null || image!.isEmpty) return '';
    if (image!.startsWith('http')) return image!;
    return '${ApiConstants.imageBaseUrl}/$image';
  }

  factory Puja.fromJson(Map<String, dynamic> json) {
    return Puja(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      slug: json['slug'] ?? '',
      image: json['image'],
      startDateTime: json['start_date_time'] ?? '',
      duration: json['duration'] ?? 0,
      place: json['place'] ?? '',
      about: json['about'] ?? '',
      benefits: (json['benefits'] as List? ?? [])
          .map((e) => PujaBenefit.fromJson(e))
          .toList(),
      packages: (json['packages'] as List? ?? [])
          .map((e) => (e is Map<String, dynamic>) 
              ? PujaPackage.fromJson(e) 
              : PujaPackage(id: e.toString(), title: '', priceInr: 0, priceUsd: 0, description: ''))
          .toList(),
      categoryId: json['categoryId'] is Map ? json['categoryId']['_id'] : json['categoryId'],
      subCategoryId: json['subCategoryId'] is Map ? json['subCategoryId']['_id'] : json['subCategoryId'],
    );
  }
}

class PujaOrderRequest {
  final String pujaId;
  final String packageId;
  final String astrologerId;
  final String bookingDate;
  final String mode; // online, offline
  final String paymentMethod; // wallet, online, cash on delivery
  final Map<String, dynamic> shippingDetails;
  final String? razorpayOrderId;
  final String? razorpayPaymentId;
  final String? razorpaySignature;

  PujaOrderRequest({
    required this.pujaId,
    required this.packageId,
    required this.astrologerId,
    required this.bookingDate,
    required this.mode,
    required this.paymentMethod,
    required this.shippingDetails,
    this.razorpayOrderId,
    this.razorpayPaymentId,
    this.razorpaySignature,
  });

  Map<String, dynamic> toJson() {
    return {
      'pujaId': pujaId,
      'packageId': packageId,
      'astrologerId': astrologerId,
      'booking_date': bookingDate,
      'mode': mode,
      'payment_method': paymentMethod,
      'shipping_details': shippingDetails,
      if (razorpayOrderId != null) 'razorpay_order_id': razorpayOrderId,
      if (razorpayPaymentId != null) 'razorpay_payment_id': razorpayPaymentId,
      if (razorpaySignature != null) 'razorpay_signature': razorpaySignature,
    };
  }
}

class PujaOrder {
  final String id;
  final String orderId;
  final String customerId;
  final String pujaId;
  final String packageId;
  final String astrologerId;
  final double amount;
  final String status;
  final String paymentStatus;
  final String paymentMethod;
  final String mode;
  final String bookingDate;
  final Map<String, dynamic>? shippingDetails;
  final String? razorpayOrderId;
  final DateTime createdAt;

  PujaOrder({
    required this.id,
    required this.orderId,
    required this.customerId,
    required this.pujaId,
    required this.packageId,
    required this.astrologerId,
    required this.amount,
    required this.status,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.mode,
    required this.bookingDate,
    this.shippingDetails,
    this.razorpayOrderId,
    required this.createdAt,
  });

  factory PujaOrder.fromJson(Map<String, dynamic> json) {
    return PujaOrder(
      id: json['_id'] ?? '',
      orderId: json['order_id'] ?? '',
      customerId: json['customer_id'] ?? '',
      pujaId: json['puja_id'] is Map ? json['puja_id']['_id'] : (json['puja_id'] ?? ''),
      packageId: json['package_id'] is Map ? json['package_id']['_id'] : (json['package_id'] ?? ''),
      astrologerId: json['astrologer_id'] is Map ? json['astrologer_id']['_id'] : (json['astrologer_id'] ?? ''),
      amount: (json['amount'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      paymentStatus: json['payment_status'] ?? '',
      paymentMethod: json['payment_method'] ?? '',
      mode: json['mode'] ?? '',
      bookingDate: json['booking_date'] ?? '',
      shippingDetails: json['shipping_details'],
      razorpayOrderId: json['razorpay_order_id'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}
