import 'dart:ui';

bool isRectInside(Rect textBoundingBox, Rect viewfinderBox) {
  return textBoundingBox.left >= viewfinderBox.left &&
      textBoundingBox.right <= viewfinderBox.right &&
      textBoundingBox.top >= viewfinderBox.top &&
      textBoundingBox.bottom <= viewfinderBox.bottom;
}
