import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

enum WebViewLoadingState {
  loading,
  loaded,
  error,
}

class WebViewLoadingOverlay extends StatelessWidget {
  final WebViewLoadingState state;
  final String loadingText;
  final String errorText;
  final String retryButtonText;
  final VoidCallback? onRetry;
  final Color? backgroundColor;
  final double opacity;
  final bool showAnimation;

  const WebViewLoadingOverlay({
    Key? key,
    required this.state,
    this.loadingText = '正在加载...',
    this.errorText = '加载失败',
    this.retryButtonText = '重试',
    this.onRetry,
    this.backgroundColor,
    this.opacity = 0.9,
    this.showAnimation = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (state == WebViewLoadingState.loaded) {
      return const SizedBox.shrink();
    }

    return Positioned.fill(
      child: AnimatedOpacity(
        opacity: state == WebViewLoadingState.loaded ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 300),
        child: Container(
          color: (backgroundColor ?? Colors.white).withOpacity(opacity),
          child: Center(
            child: _buildContent(context),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (state) {
      case WebViewLoadingState.loading:
        return _buildLoadingContent(context);
      case WebViewLoadingState.error:
        return _buildErrorContent(context);
      case WebViewLoadingState.loaded:
        return const SizedBox.shrink();
    }
  }

  Widget _buildLoadingContent(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showAnimation)
          _buildAnimatedLoadingIndicator(context),
        const SizedBox(height: 16),
        Text(
          loadingText,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedLoadingIndicator(BuildContext context) {
    final color = Theme.of(context).primaryColor;
    return SizedBox(
      width: 56,
      height: 56,
      child: CircularProgressIndicator(
        strokeWidth: 4,
        valueColor: AlwaysStoppedAnimation<Color>(color),
        backgroundColor: color.withOpacity(0.15),
      ),
    );
    // 如果需要使用 Lottie 动画，可以取消下面的注释并添加相应的 Lottie 文件
    // return SizedBox(
    //   width: 150,
    //   height: 150,
    //   child: Lottie.asset(
    //     'assets/lottie/lottie_loading.json',
    //     width: 150,
    //     height: 150,
    //     fit: BoxFit.contain,
    //     repeat: true,
    //   ),
    // );
  }

  Widget _buildErrorContent(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.errorContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.error,
            size: 48,
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            errorText,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.error,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(retryButtonText),
            ),
            const SizedBox(width: 16),
            OutlinedButton(
              onPressed: () {
                // 可以添加关闭 WebView 的功能
                Navigator.of(context).pop();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.onSurface,
                side: BorderSide(color: Theme.of(context).colorScheme.outline),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('取消'),
            ),
          ],
        ),
      ],
    );
  }
}