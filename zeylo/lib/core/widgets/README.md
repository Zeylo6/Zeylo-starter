# Zeylo Reusable Widgets Library

Complete set of 12 production-ready, reusable widget components for the Zeylo community-driven platform for local experiences.

## Overview

This directory contains a comprehensive library of reusable, well-documented Flutter widgets that follow the Zeylo design system. All widgets are built with:
- **Consistency**: Aligned with AppColors, AppTypography, AppSpacing, AppRadius, AppShadows
- **Reusability**: Self-contained, composable components
- **Production Quality**: Thoroughly documented, null-safe, and tested patterns
- **Accessibility**: Semantic widgets with proper contrast and touch targets
- **Customization**: Extensive parameters for color, size, and behavior

## Quick Navigation

### Input Widgets
- [`custom_button.dart`](#zeylobutton) - ZeyloButton with filled/outlined variants
- [`custom_text_field.dart`](#zeylotext field) - ZeyloTextField with validation support
- [`phone_input_field.dart`](#phoneinputfield) - PhoneInputField with auto-formatting

### Display Widgets
- [`experience_card.dart`](#experiencecard) - ExperienceCard with image, host info, and ratings
- [`host_avatar.dart`](#hostavatar) - HostAvatar with badges and online indicator
- [`rating_widget.dart`](#ratingwidget) - RatingWidget for interactive/display ratings

### Navigation & Layout
- [`bottom_nav_bar.dart`](#zeylbottomnav bar) - ZeyloBottomNavBar with 4 icon tabs
- [`section_header.dart`](#sectionheader) - SectionHeader with title and action

### Selection & Filtering
- [`mood_chip.dart`](#moodchip) - MoodChip for mood categories and interest tags

### Loading States
- [`loading_shimmer.dart`](#shimmer-components) - Multiple shimmer skeletons

### Empty/Error States
- [`error_widget.dart`](#error-widgets) - Error state variants
- [`empty_state_widget.dart`](#empty-state-widgets) - Empty state variants

## Widget Details

### ZeyloButton
**File**: `custom_button.dart`

Button component with two variants and support for loading/disabled states.

```dart
ZeyloButton(
  onPressed: () => print('Pressed'),
  label: 'Continue',
  variant: ButtonVariant.filled,  // or .outlined
  isLoading: false,
  icon: Icons.arrow_forward,
)
```

**Features**:
- Filled variant (purple background, white text)
- Outlined variant (purple border, purple text)
- Loading state with CircularProgressIndicator
- Disabled state (50% opacity)
- Optional leading icon
- Customizable width, height, and border radius

---

### ZeyloTextField
**File**: `custom_text_field.dart`

Text input field with label, hint, and validation support.

```dart
ZeyloTextField(
  label: 'Email Address',
  hint: 'Enter your email',
  controller: emailController,
  keyboardType: TextInputType.emailAddress,
  errorText: _emailError,
  prefixWidget: Icon(Icons.email),
  suffixWidget: Icon(Icons.check),
)
```

**Features**:
- Label above field
- Hint text inside
- Rounded border with light color, purple on focus
- Optional prefix widget (e.g., flag for country code)
- Optional suffix widget (e.g., visibility toggle)
- Auto obscure text toggle for passwords
- Error text display
- Full customization of styles

---

### ExperienceCard
**File**: `experience_card.dart`

Card component displaying an experience with image, host info, and metadata.

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
  matchPercentage: 98,
  onTap: () => viewExperience(),
  onFavoriteTap: () => toggleFavorite(),
)
```

**Features**:
- CachedNetworkImage with shimmer placeholder
- Toggleable favorite heart icon
- Host avatar and name
- Location with pin icon
- Price display
- Description preview with "See more" link
- Rating badge
- Optional match percentage badge
- Rounded corners and subtle shadow

---

### HostAvatar
**File**: `host_avatar.dart`

Circular avatar component for host profiles with optional badges.

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

**Features**:
- Three sizes: small (32), medium (48), large (80)
- Verified badge (purple checkmark)
- Superhost label below avatar
- Online indicator (green dot)
- Fallback to initials on missing image
- Image loading with fallback states

---

### RatingWidget
**File**: `rating_widget.dart`

Star rating display and interactive rating component.

```dart
// Display mode
RatingWidget(
  rating: 4.8,
  ratingCount: 234,
  isInteractive: false,
)

// Interactive mode
RatingWidget(
  rating: 0,
  isInteractive: true,
  onRatingChanged: (rating) => submitRating(rating),
)
```

**Features**:
- Display mode (show-only) and interactive mode (tap to rate)
- Half-star support for precise ratings
- Shows rating number and count (e.g., "4.9 (234)")
- Customizable star size
- Horizontal or vertical axis
- Purple color for filled stars

---

### ZeyloBottomNavBar
**File**: `bottom_nav_bar.dart`

Bottom navigation bar with 4 icon-only items.

```dart
ZeyloBottomNavBar(
  currentIndex: _currentIndex,
  onTap: (index) => setState(() => _currentIndex = index),
)
```

**Features**:
- 4 items: Home, Discover, Explore, Profile
- Selected item purple, unselected grey
- Icon-only design (no labels)
- Clean white background with top border
- Safe area padding support

---

### PhoneInputField
**File**: `phone_input_field.dart`

Specialized text field for Sri Lankan phone numbers.

```dart
PhoneInputField(
  label: 'Phone Number',
  controller: phoneController,
  onChanged: (value) => print('Phone: $value'),
)
```

**Features**:
- Sri Lankan flag emoji (🇱🇰) prefix
- Country code (+94) display
- Auto-formatting to 07X XXX XXXX format
- Strips country code on value submission
- Same styling as ZeyloTextField
- Input validation support

---

### SectionHeader
**File**: `section_header.dart`

Header component for content sections with optional action.

```dart
SectionHeader(
  title: 'Popular Experiences',
  actionText: 'See all',
  onActionTap: () => viewAllExperiences(),
  icon: Icons.star,
)
```

**Features**:
- Title on left (bold)
- Optional icon before title
- Optional action text on right
- Action button with callback
- Customizable padding and spacing

---

### MoodChip
**File**: `mood_chip.dart`

Chip component for mood categories, interests, and filters.

```dart
// Stateful chip
MoodChip(
  label: 'Adventure',
  icon: Icons.hiking,
  isSelected: true,
  onTap: () => toggleMood('Adventure'),
)

// Stateless chip (manage state externally)
SelectableMoodChip(
  label: 'Adventure',
  icon: Icons.hiking,
  isSelected: _moods.contains('Adventure'),
  onTap: () => toggleMood('Adventure'),
)
```

**Features**:
- Icon + text layout
- Selected state (purple background/border)
- Unselected state (grey border)
- Two variants: stateful and stateless
- Fully customizable colors and sizes

---

### Shimmer Components
**File**: `loading_shimmer.dart`

Loading skeleton placeholders with shimmer animation.

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

**Features**:
- Multiple pre-built skeleton layouts
- Light grey shimmer animation
- Responsive dimensions
- Matches actual component sizes

---

### Error Widgets
**File**: `error_widget.dart`

Error state display components.

```dart
// Base error widget
ZeyloErrorWidget(
  title: 'Something went wrong',
  message: 'Please check and try again',
  icon: Icons.error_outline,
  onTryAgain: () => retry(),
)

// No data variant
ZeyloNoDataWidget()

// Network error variant
ZeyloNetworkErrorWidget(onTryAgain: () => retry())
```

**Features**:
- Customizable icon (red by default)
- Error title and message
- "Try Again" button with callback
- Multiple pre-built variants
- Centered or left-aligned layouts

---

### Empty State Widgets
**File**: `empty_state_widget.dart`

Empty state display components for various scenarios.

```dart
// Base empty state
EmptyStateWidget(
  icon: Icons.favorite_outline,
  title: 'No Favorites Yet',
  subtitle: 'Start adding experiences',
  actionLabel: 'Explore',
  onAction: () => explore(),
)

// Pre-built variants
EmptyFavoritesWidget(onExplore: () => {})
EmptySearchResultsWidget(searchQuery: 'yoga')
EmptyNotificationsWidget()
EmptyChatsWidget(onBrowse: () => {})
```

**Features**:
- Customizable icon, title, subtitle
- Optional action button
- Multiple pre-built variants for common scenarios
- Centered or left-aligned layouts

---

## Design System Integration

All widgets use the Zeylo design tokens:

### Colors (AppColors)
```dart
AppColors.primary           // #8B5CF6 (Purple)
AppColors.textPrimary      // #1F2937 (Dark gray)
AppColors.textSecondary    // #6B7280 (Medium gray)
AppColors.border           // #E5E7EB (Light border)
AppColors.error            // #EF4444 (Red)
AppColors.success          // #22C55E (Green)
```

### Spacing (AppSpacing)
```dart
AppSpacing.xs      // 4
AppSpacing.sm      // 8
AppSpacing.md      // 12
AppSpacing.lg      // 16
AppSpacing.xl      // 20
AppSpacing.xxl     // 24
```

### Radius (AppRadius)
```dart
AppRadius.md       // 12 (inputs)
AppRadius.lg       // 16 (buttons, cards)
AppRadius.full     // 999 (circles)
```

### Typography (AppTypography)
```dart
AppTypography.headlineSmall     // Section headings
AppTypography.titleLarge        // Card titles
AppTypography.bodyMedium        // Body text
AppTypography.labelLarge        // Button labels
```

## Installation & Setup

### 1. Add Dependencies
Ensure your `pubspec.yaml` includes:

```yaml
dependencies:
  flutter:
    sdk: flutter
  cached_network_image: ^3.2.0
  shimmer: ^3.0.0
```

### 2. Get Dependencies
```bash
flutter pub get
```

### 3. Import Widgets
```dart
// Option 1: Import all widgets at once (recommended)
import 'package:zeylo/core/widgets/index.dart';

// Option 2: Import specific widgets
import 'package:zeylo/core/widgets/custom_button.dart';
import 'package:zeylo/core/widgets/experience_card.dart';
```

## Usage Examples

### Form with Validation
```dart
Column(
  children: [
    ZeyloTextField(
      label: 'Full Name',
      hint: 'Enter your name',
      controller: nameController,
      errorText: _nameError,
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

### Experience List with Loading
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

### Mood Selection
```dart
Wrap(
  spacing: AppSpacing.md,
  children: _moods
      .map((mood) => MoodChip(
            label: mood.name,
            icon: mood.icon,
            isSelected: _selectedMoods.contains(mood),
            onTap: () => _toggleMood(mood),
          ))
      .toList(),
)
```

### Navigation with Bottom Nav
```dart
Scaffold(
  body: _buildBody(_currentIndex),
  bottomNavigationBar: ZeyloBottomNavBar(
    currentIndex: _currentIndex,
    onTap: (index) => setState(() => _currentIndex = index),
  ),
)
```

## Best Practices

1. **Use const constructors** where possible for performance
2. **Handle nullability** - widgets have sensible defaults
3. **Validate inputs** - textfields support error states
4. **Test interactions** - all widgets are interaction-aware
5. **Follow spacing** - use AppSpacing constants consistently
6. **Maintain accessibility** - widgets include semantic support
7. **Monitor images** - use CachedNetworkImage for performance
8. **Provide feedback** - buttons have loading and disabled states
9. **Handle loading** - use shimmer placeholders
10. **Show states** - provide empty/error states

## Troubleshooting

### Images not loading
- Ensure URLs are valid and reachable
- Verify cached_network_image is in pubspec.yaml
- Check network permissions in app manifest

### Shimmer not animating
- Verify shimmer package is installed
- Ensure devices supports animation (not in power-saver mode)

### Buttons not responding
- Check onPressed is provided and not null
- Verify isDisabled is false

### TextField focus color not changing
- Ensure AppColors is imported correctly
- Check theme files exist and are valid

## File Statistics

- **Total Lines**: ~2,746
- **Number of Widgets**: 12 + 8 variants
- **Average File Size**: 5.2 KB
- **Largest File**: experience_card.dart (9.9 KB)
- **Documentation**: Comprehensive with examples

## Support

For questions or issues with widgets:
1. Check WIDGETS_GUIDE.md for detailed documentation
2. Review example usage in docstrings
3. Verify design system compatibility
4. Test with minimal reproducible example

## Version

- **Widget Library Version**: 1.0
- **Created**: February 24, 2026
- **Flutter Minimum**: 3.0+
- **Null Safety**: Enabled

## License

All widgets are part of the Zeylo application and follow the project's licensing terms.

---

**Developed for Zeylo - A community-driven platform for local experiences**
