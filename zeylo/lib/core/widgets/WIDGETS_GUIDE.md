# Zeylo Flutter App - Reusable Widgets Guide

## Overview
Complete set of 12 production-ready, reusable widget components for the Zeylo community-driven platform. All widgets follow the design system defined in `/lib/core/theme/`.

## Quick Reference

### Input Widgets

#### ZeyloButton
Location: `custom_button.dart`
```dart
ZeyloButton(
  onPressed: () => {},
  label: 'Continue',
  variant: ButtonVariant.filled,
  isLoading: false,
  isDisabled: false,
  icon: null,
)
```
- **Variants**: `filled` (purple bg), `outlined` (purple border)
- **States**: normal, loading, disabled
- **Customization**: width, height, borderRadius, icon

#### ZeyloTextField
Location: `custom_text_field.dart`
```dart
ZeyloTextField(
  label: 'Email Address',
  hint: 'Enter your email',
  controller: emailController,
  keyboardType: TextInputType.emailAddress,
  errorText: 'Invalid email',
)
```
- **Features**: label + hint, prefix/suffix widgets, error text, obscure toggle
- **Keyboard Types**: text, email, phone, number, etc.
- **State**: enabled/disabled, with validation

#### PhoneInputField
Location: `phone_input_field.dart`
```dart
PhoneInputField(
  label: 'Phone Number',
  controller: phoneController,
  onChanged: (value) => print('Phone: $value'),
)
```
- **Auto-formatting**: 07X XXX XXXX
- **Country Code**: +94 (Sri Lanka)
- **Returns**: formatted and unformatted values

### Display Widgets

#### ExperienceCard
Location: `experience_card.dart`
```dart
ExperienceCard(
  imageUrl: 'https://example.com/image.jpg',
  hostName: 'John Doe',
  hostAvatarUrl: 'https://example.com/avatar.jpg',
  location: 'Colombo, Sri Lanka',
  price: 'LKR 2,500',
  description: 'Amazing experience...',
  rating: 4.8,
  ratingCount: 234,
  isFavorite: false,
  matchPercentage: 98,
  onTap: () => {},
  onFavoriteTap: () => {},
)
```
- **Layout**: Image + Host Info + Details
- **Features**: Favorite toggle, Rating badge, Match percentage
- **Image Loading**: Shimmer placeholder with CachedNetworkImage

#### HostAvatar
Location: `host_avatar.dart`
```dart
HostAvatar(
  imageUrl: 'https://example.com/avatar.jpg',
  hostName: 'John Doe',
  size: AvatarSize.large,
  isVerified: true,
  isSuperhost: true,
  isOnline: true,
)
```
- **Sizes**: small (32), medium (48), large (80)
- **Badges**: Verified (checkmark), Superhost (label), Online (green dot)
- **Fallback**: Initials if no image

#### RatingWidget
Location: `rating_widget.dart`
```dart
RatingWidget(
  rating: 4.8,
  ratingCount: 234,
  isInteractive: false,
  starSize: 20,
  onRatingChanged: (rating) => {},
)
```
- **Modes**: Display-only or Interactive
- **Display**: Stars + "4.9 (234)" text
- **Interactions**: Tap stars to rate

### Navigation Widgets

#### ZeyloBottomNavBar
Location: `bottom_nav_bar.dart`
```dart
ZeyloBottomNavBar(
  currentIndex: 0,
  onTap: (index) => setState(() => _currentIndex = index),
)
```
- **Items**: Home, Discover, Explore, Profile (icons only)
- **Colors**: Purple (selected), Grey (unselected)
- **Safe Area**: Built-in bottom padding support

#### SectionHeader
Location: `section_header.dart`
```dart
SectionHeader(
  title: 'Popular Experiences',
  actionText: 'See all',
  onActionTap: () => {},
  icon: Icons.star,
)
```
- **Layout**: Title (left) + Action (right)
- **Optional**: Leading icon, action text and callback
- **Customization**: alignment, padding, icon gap

### Selection Widgets

#### MoodChip
Location: `mood_chip.dart`
```dart
MoodChip(
  label: 'Adventure',
  icon: Icons.hiking,
  isSelected: true,
  onTap: () => {},
)
```
- **States**: Selected (purple bg/border), Unselected (grey)
- **Content**: Icon + Text
- **Uses**: Mood categories, interest tags, filters
- **Variants**: `MoodChip` (stateful), `SelectableMoodChip` (stateless)

### Loading States

#### Shimmer Components
Location: `loading_shimmer.dart`
```dart
// Experience card skeleton
ShimmerExperienceCard(height: 320)

// Profile header skeleton
ShimmerProfileHeader(height: 200)

// List tile skeleton
ShimmerListTile(showAvatar: true)

// Text line skeleton
ShimmerText(lineCount: 3)

// Grid skeleton
ShimmerGrid(crossAxisCount: 2, itemCount: 4)
```
- **All use shimmer package** with light grey animation
- **Responsive**: Match actual component layouts

### Empty/Error States

#### EmptyStateWidget
Location: `empty_state_widget.dart`
```dart
EmptyStateWidget(
  icon: Icons.favorite_outline,
  title: 'No Favorites Yet',
  subtitle: 'Start adding experiences to your favorites',
  actionLabel: 'Explore',
  onAction: () => {},
)
```
- **Customization**: Icon, title, subtitle, action button
- **Variants**:
  - `EmptyFavoritesWidget`
  - `EmptySearchResultsWidget`
  - `EmptyNotificationsWidget`
  - `EmptyChatsWidget`

#### Error Widgets
Location: `error_widget.dart`
```dart
ZeyloErrorWidget(
  title: 'Something went wrong',
  message: 'Please check and try again',
  icon: Icons.error_outline,
  onTryAgain: () => {},
)
```
- **Base**: `ZeyloErrorWidget` (customizable)
- **Variants**:
  - `ZeyloNoDataWidget`
  - `ZeyloNetworkErrorWidget`

## Theme Integration

All widgets use the Zeylo design system:

### Colors
- **Primary**: `AppColors.primary` (#8B5CF6)
- **Text**: `AppColors.textPrimary`, `textSecondary`, `textHint`
- **Borders**: `AppColors.border`
- **Semantic**: `AppColors.error`, `success`, `warning`

### Spacing
- **Standard**: `AppSpacing.xs` (4), `sm` (8), `md` (12), `lg` (16), `xl` (20), `xxl` (24)
- **Used throughout** for padding, margins, gaps

### Radius
- **Buttons/Cards**: `AppRadius.lg` (16)
- **Inputs**: `AppRadius.md` (12)
- **Circular**: `AppRadius.full` (999)

### Typography
- **Headings**: `AppTypography.headlineSmall/Medium/Large`
- **Body**: `AppTypography.bodyMedium/Small`
- **Labels**: `AppTypography.labelLarge/Medium`

### Shadows
- **Cards**: `AppShadows.card` or `AppShadows.elevatedCard`
- **Modals**: `AppShadows.modal`
- **Primary Glow**: `AppShadows.primaryGlow`

## Import Pattern

### Option 1: Import individual widgets
```dart
import 'package:zeylo/core/widgets/custom_button.dart';
import 'package:zeylo/core/widgets/experience_card.dart';
```

### Option 2: Import from index (recommended)
```dart
import 'package:zeylo/core/widgets/index.dart';

// Access all widgets:
// - ZeyloButton
// - ZeyloTextField
// - ExperienceCard
// - HostAvatar
// - RatingWidget
// - ShimmerExperienceCard, ShimmerProfileHeader, etc.
// - ZeyloErrorWidget, ZeyloNoDataWidget, etc.
// - EmptyStateWidget, EmptyFavoritesWidget, etc.
// - ZeyloBottomNavBar
// - PhoneInputField
// - SectionHeader
// - MoodChip
```

## Common Patterns

### Form with Validation
```dart
Column(
  children: [
    ZeyloTextField(
      label: 'Full Name',
      hint: 'Enter your full name',
      controller: nameController,
      errorText: _nameError,
      onChanged: (value) => _validateName(value),
    ),
    PhoneInputField(
      label: 'Phone Number',
      controller: phoneController,
      errorText: _phoneError,
    ),
    const SizedBox(height: AppSpacing.lg),
    ZeyloButton(
      onPressed: _isValid ? _submit : null,
      label: 'Continue',
      isLoading: _isLoading,
    ),
  ],
)
```

### List with Loading
```dart
ListView.builder(
  itemCount: _isLoading ? 3 : _experiences.length,
  itemBuilder: (context, index) {
    if (_isLoading) {
      return const ShimmerExperienceCard();
    }
    return ExperienceCard(
      imageUrl: _experiences[index].imageUrl,
      hostName: _experiences[index].hostName,
      location: _experiences[index].location,
      price: _experiences[index].price,
      description: _experiences[index].description,
      onTap: () => _viewExperience(_experiences[index]),
    );
  },
)
```

### Filter UI with Chips
```dart
Wrap(
  spacing: AppSpacing.md,
  runSpacing: AppSpacing.md,
  children: [
    'Adventure',
    'Relaxation',
    'Culture',
  ]
      .map((mood) => MoodChip(
            label: mood,
            isSelected: _selectedMoods.contains(mood),
            onTap: () => _toggleMood(mood),
          ))
      .toList(),
)
```

### Empty State Handling
```dart
if (_favorites.isEmpty) {
  return EmptyFavoritesWidget(
    onExplore: () => Navigator.push(...),
  );
}

// Show list...
```

## Widget Compatibility

All widgets are fully compatible with:
- **Flutter**: 3.0+
- **Null Safety**: Enabled
- **State Management**: Works with Provider, Riverpod, GetX, Bloc, etc.
- **Responsive**: Mobile-first, tablet-friendly
- **Accessibility**: Semantic widgets, proper contrast

## Dependencies Required

Ensure these are in `pubspec.yaml`:
```yaml
dependencies:
  flutter:
    sdk: flutter
  cached_network_image: ^3.2.0
  shimmer: ^3.0.0
```

Run: `flutter pub get`

## File Structure

```
lib/core/widgets/
├── index.dart                    # Central export
├── custom_button.dart            # ZeyloButton
├── custom_text_field.dart        # ZeyloTextField
├── experience_card.dart          # ExperienceCard
├── host_avatar.dart              # HostAvatar
├── rating_widget.dart            # RatingWidget
├── loading_shimmer.dart          # Shimmer components
├── error_widget.dart             # Error states
├── empty_state_widget.dart       # Empty states
├── bottom_nav_bar.dart           # Navigation
├── phone_input_field.dart        # Phone input
├── section_header.dart           # Section headers
└── mood_chip.dart                # Chips
```

## Best Practices

1. **Use const constructors** where possible for performance
2. **Cache widget references** in state if reusing frequently
3. **Handle nullability** - widgets have sensible defaults
4. **Test interactions** - all widgets are interaction-aware
5. **Follow spacing** - use AppSpacing constants consistently
6. **Maintain accessibility** - widgets include semantic support
7. **Monitor images** - use CachedNetworkImage for performance
8. **Validate inputs** - textfields support error states
9. **Handle loading** - use shimmer placeholders
10. **Provide feedback** - buttons have loading and disabled states

---

**Version**: 1.0
**Last Updated**: February 24, 2026
**Theme System**: AppColors, AppTypography, AppSpacing, AppRadius, AppShadows
