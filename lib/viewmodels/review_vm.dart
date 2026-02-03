import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/review.dart';

class ReviewViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<Review> _reviews = [];
  Review? _draftReview;
  bool _isLoading = false;
  String? _errorMessage;

  List<Review> get reviews => List.unmodifiable(_reviews);
  Review? get draftReview => _draftReview;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> createReview({
    required String shopId,
    required String userId,
    required String orderId,
    required double rating,
    String comment = '',
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final review = Review(
        id: '',
        shopId: shopId,
        userId: userId,
        orderId: orderId,
        rating: rating,
        comment: comment,
        createdAt: DateTime.now(),
      );

      final reviewMap = {
        'shopId': shopId,
        'userId': userId,
        'orderId': orderId,
        'rating': rating,
        'comment': comment,
        'createdAt': review.createdAt.toIso8601String(),
      };

      final docRef = await _firestore.collection('reviews').add(reviewMap);

      final createdReview = review.copyWith(id: docRef.id);

      _reviews.insert(0, createdReview);
      _draftReview = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void saveDraft({
    required String shopId,
    required String userId,
    required String orderId,
    required double rating,
    String comment = '',
  }) {
    _draftReview = Review(
      id: 'draft_${DateTime.now().millisecondsSinceEpoch}',
      shopId: shopId,
      userId: userId,
      orderId: orderId,
      rating: rating,
      comment: comment,
      createdAt: DateTime.now(),
    );
    notifyListeners();
  }

  Future<void> loadReviewsForShop(String shopId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final querySnapshot =
          await _firestore
              .collection('reviews')
              .where('shopId', isEqualTo: shopId)
              .orderBy('createdAt', descending: true)
              .get();

      _reviews.clear();
      for (var doc in querySnapshot.docs) {
        final review = _reviewFromFirestore(doc);
        if (review != null) {
          _reviews.add(review);
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadReviewsForOrder(String orderId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final querySnapshot =
          await _firestore
              .collection('reviews')
              .where('orderId', isEqualTo: orderId)
              .orderBy('createdAt', descending: true)
              .get();

      _reviews.clear();
      for (var doc in querySnapshot.docs) {
        final review = _reviewFromFirestore(doc);
        if (review != null) {
          _reviews.add(review);
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Review? _reviewFromFirestore(DocumentSnapshot doc) {
    try {
      final data = doc.data() as Map<String, dynamic>;
      return Review(
        id: doc.id,
        shopId: data['shopId'] as String,
        userId: data['userId'] as String,
        orderId: data['orderId'] as String,
        rating: ((data['rating'] ?? 0) as num).toDouble(),
        comment: (data['comment'] ?? '') as String,
        createdAt: DateTime.parse(data['createdAt'] as String),
      );
    } catch (e) {
      return null;
    }
  }

  List<Review> getReviewsForShop(String shopId) {
    return _reviews.where((review) => review.shopId == shopId).toList();
  }

  double getAverageRatingForShop(String shopId) {
    final shopReviews = getReviewsForShop(shopId);
    if (shopReviews.isEmpty) return 0.0;

    final totalRating = shopReviews.fold(
      0.0,
      (sum, review) => sum + review.rating,
    );
    return totalRating / shopReviews.length;
  }

  void clearDraft() {
    _draftReview = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Refresh reviews.
  Future<void> refresh() async {
    // Reload reviews based on current context
    notifyListeners();
  }
}
