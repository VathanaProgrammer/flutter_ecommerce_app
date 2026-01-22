import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../../providers/cart_provider.dart';
import '../../services/qr_payment_service.dart';
import '../../google/map/map_location_picker.dart';
import '../payments/payment_completed_screen.dart';
import '../payments/cash_payment_completed_screen.dart';
import 'package:flutter/cupertino.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _currentStep = 0;

  // Step 1: Shipping Address
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _shipping_address_controller = TextEditingController();
  final _noteController = TextEditingController();
  double? _latitude;
  double? _longitude;

  // Step 2: Payment Method
  String _paymentMethod = 'cash';

  // QR Payment
  String? _tranId;
  String? _qrImage;
  bool _checkingPayment = false;

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    _shipping_address_controller.dispose();
    _noteController.dispose();
    super.dispose();
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        if (_addressController.text.trim().isEmpty) {
          _showError('Please select your delivery address');
          return false;
        }
        if (_phoneController.text.trim().isEmpty) {
          _showError('Please enter your phone number');
          return false;
        }
        if (_shipping_address_controller.text.trim().isEmpty) {
          _showError('Please enter your shipping address');
          return false;
        }
        return true;
      default:
        return true;
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _selectLocation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MapLocationPicker()),
    );

    if (result != null) {
      setState(() {
        _addressController.text = result['address'];
        _latitude = result['latitude'];
        _longitude = result['longitude'];
      });
    }
  }

  Future<void> _generateQRCode() async {
    final cart = context.read<CartProvider>();

    setState(() => _checkingPayment = true);

    try {
      // Build payload snapshot
      final payloadSnapshot = {
        'items': cart.items
            .map(
              (item) => {
                'product_id': item.product.id,
                'quantity': item.quantity,
                'price': item.product.price,
                'discount': item.product.discount != null
                    ? {
                        'value': item.product.discount!.value,
                        'is_percentage': item.product.discount!.isPercentage,
                      }
                    : null,
              },
            )
            .toList(),
        'subtotal': cart.subtotal,
        'shipping_charge': cart.shippingCharge,
        'total': cart.total,
        'shipping_address': _shipping_address_controller.text,
        'more_address': {
          'address': _addressController.text,
          'phone': _phoneController.text,
          'note': _noteController.text,
          'latitude': _latitude,
          'longitude': _longitude,
        },
      };

      // Call backend with correct parameters
      final qrData = await QRPaymentService.createPaymentIntent(
        payloadSnapshot: payloadSnapshot,
      );

      setState(() {
        _tranId = qrData['tran_id'];
        _qrImage = qrData['qr_image'];
        _checkingPayment = false;
        _currentStep = 3; // Go to QR payment step
      });

      // Automatically "scan" and check payment after 2 seconds
      Future.delayed(const Duration(seconds: 2), () async {
        if (_tranId != null) {
          await _checkPayment();
        }
      });
    } catch (e) {
      setState(() => _checkingPayment = false);
      print('failed to generate QR $e');
      _showError('Failed to generate QR code: $e');
    }
  }

  Future<void> _checkPayment() async {
    if (_tranId == null) return;

    setState(() => _checkingPayment = true);

    try {
      final isPaid = await QRPaymentService.autoPayAfter2Sec(_tranId!);
      if (isPaid) {
        final cart = context.read<CartProvider>();
        cart.clear();
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => PaymentCompletedScreen(
                tranId: _tranId!,
                amount: context.read<CartProvider>().total,
              ),
            ),
          );
        }
      } else {
        _showError('Payment not received yet. Please try again.');
      }
    } catch (e) {
      _showError('Error checking payment: $e');
    } finally {
      setState(() => _checkingPayment = false);
    }
  }

  Future<void> _cashCheckout() async {
    final cart = context.read<CartProvider>();

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 24),
              Text(
                'Processing Order',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      // Build payload snapshot
      final payloadSnapshot = {
        'items': cart.items
            .map(
              (item) => {
                'product_id': item.product.id,
                'quantity': item.quantity,
                'price': item.product.price,
                'discount': item.product.discount != null
                    ? {
                        'value': item.product.discount!.value,
                        'is_percentage': item.product.discount!.isPercentage,
                      }
                    : null,
              },
            )
            .toList(),
        'subtotal': cart.subtotal,
        'shipping_charge': cart.shippingCharge,
        'total': cart.total,
        'shipping_address': _shipping_address_controller.text,
        'more_address': {
          'address': _addressController.text,
          'phone': _phoneController.text,
          'note': _noteController.text,
          'latitude': _latitude,
          'longitude': _longitude,
        },
      };

      // Call provider function
      final result = await cart.checkoutCash(payloadSnapshot: payloadSnapshot);

      if (mounted) Navigator.pop(context); // Close loading dialog

      final isSuccess = result['isSuccess'] as bool;
      final message = result['output'][0]['message'] as String;

      if (isSuccess) {
        final cart = context.read<CartProvider>();
        cart.clear(); // ✅ CLEAR IT
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => CashCompletedScreen(amount: cart.total),
            ),
          );
        }
      } else {
        if (mounted) {
          // Show error message
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Checkout Failed'),
              content: Text(message),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Checkout Error'),
            content: Text(e.toString().replaceAll('Exception: ', '')),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Checkout',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          _buildStepIndicator(),
          Expanded(
            child: IndexedStack(
              index: _currentStep,
              children: [
                _buildShippingStep(),
                _buildPaymentStep(),
                _buildReviewStep(),
                _buildQRPaymentStep(),
              ],
            ),
          ),
          _buildBottomButtons(),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    final stepCount = _paymentMethod == 'qr' ? 4 : 3;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Row(
        children: [
          _buildStepCircle(0, 'Address'),
          _buildStepLine(0),
          _buildStepCircle(1, 'Payment'),
          _buildStepLine(1),
          _buildStepCircle(2, 'Review'),
          if (_paymentMethod == 'qr') ...[
            _buildStepLine(2),
            _buildStepCircle(3, 'Pay'),
          ],
        ],
      ),
    );
  }

  Widget _buildStepCircle(int step, String label) {
    final isActive = step == _currentStep;
    final isCompleted = step < _currentStep;

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCompleted || isActive ? Colors.black : Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                  : Text(
                      '${step + 1}',
                      style: TextStyle(
                        color: isActive ? Colors.white : Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              color: isActive ? Colors.black : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepLine(int step) {
    final isCompleted = step < _currentStep;
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 30),
        color: isCompleted ? Colors.black : Colors.grey[300],
      ),
    );
  }

  Widget _buildShippingStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Delivery Address',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          GestureDetector(
            onTap: _selectLocation,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.red),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _addressController.text.isEmpty
                          ? 'Select location on map'
                          : _addressController.text,
                      style: TextStyle(
                        color: _addressController.text.isEmpty
                            ? Colors.grey[600]
                            : Colors.black,
                      ),
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _shipping_address_controller,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              labelText: 'Shpping Address *',
              hintText: 'Enter Shipping Address',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.location_on),
            ),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Phone Number *',
              hintText: 'Enter your phone number',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.phone),
            ),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _noteController,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'Delivery Note (Optional)',
              hintText: 'Add any special instructions',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.note),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Method',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          _buildPaymentOption(
            value: 'cash',
            title: 'Cash on Delivery',
            subtitle: 'Pay when you receive',
            icon: Icons.money,
          ),
          const SizedBox(height: 12),

          _buildPaymentOption(
            value: 'qr',
            title: 'QR Payment (ABA)',
            subtitle: 'Scan and pay with ABA mobile',
            icon: Icons.qr_code,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required String value,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _paymentMethod == value;

    return InkWell(
      onTap: () => setState(() => _paymentMethod = value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected ? Colors.black : Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            if (isSelected) const Icon(Icons.check_circle, color: Colors.black),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewStep() {
    return Consumer<CartProvider>(
      builder: (context, cart, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Order Summary',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              _buildInfoCard(
                title: 'Delivery Address',
                icon: Icons.location_on,
                children: [
                  Text(_addressController.text),
                  const SizedBox(height: 8),
                  Text('Phone: ${_phoneController.text}'),
                  if (_noteController.text.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text('Note: ${_noteController.text}'),
                  ],
                ],
              ),
              const SizedBox(height: 16),

              _buildInfoCard(
                title: 'Payment Method',
                icon: Icons.payment,
                children: [Text(_getPaymentMethodName())],
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildPriceRow('Subtotal', cart.subtotal),
                    const SizedBox(height: 8),
                    const Divider(),
                    const SizedBox(height: 8),
                    _buildPriceRow('Total', cart.total, isTotal: true),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQRPaymentStep() {
    if (_qrImage == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final bytes = base64Decode(_qrImage!.split(',')[1]);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'Scan QR Code to Pay',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Image.memory(bytes, width: 250, height: 250),
          ),
          const SizedBox(height: 24),

          Consumer<CartProvider>(
            builder: (context, cart, _) => Text(
              'Amount: \$${cart.total.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),

          Text(
            'Transaction ID: $_tranId',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

          const Text(
            'Open ABA mobile app and scan this QR code to complete payment',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _getPaymentMethodName() {
    return _paymentMethod == 'cash' ? 'Cash on Delivery' : 'QR Payment (ABA)';
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _currentStep--),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Colors.black),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Back',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _checkingPayment
                    ? null
                    : () {
                        if (_currentStep < 2) {
                          if (_validateCurrentStep()) {
                            setState(() => _currentStep++);
                          }
                        } else if (_currentStep == 2) {
                          if (_paymentMethod == 'cash') {
                            _cashCheckout();
                          } else {
                            _generateQRCode();
                          }
                        } else if (_currentStep == 3) {
                          _checkPayment();
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _checkingPayment
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        _currentStep < 2
                            ? 'Continue'
                            : _currentStep == 2
                            ? _paymentMethod == 'cash'
                                  ? 'Place Order'
                                  : 'Pay With QR'
                            : 'I Have Paid',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
