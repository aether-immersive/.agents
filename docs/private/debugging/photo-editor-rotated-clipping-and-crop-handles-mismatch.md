---
tags:
  - ai-generated
  - debugging
date: 2026-06-26
source: gemini-cli
related: []
---

# Photo Editor Rotated Clipping and Crop Handles Mismatch

## Context
Fixed image transforms (rotation, scaling, flipping) cutting off vertical images, distorting crop handles, or causing incorrect zooming/cropping feedback loops in PhotoEditor.cshtml and CreatePAEAuctionItem.cshtml.

## Detail
1. Rotating landscape images by 90 degrees swaps width and height. Overriding `container.style.width` and `container.style.height` without clearing the browser's CSS constraints like `.pe-image-wrap { max-width: 100% }` caused the container to squish and distort.
2. Crop handles and the polygon mask were positioned using visual space coordinates that did not track transformed coordinates, causing visual misalignment and incorrect crop outputs when scaling or rotating.
3. In "Done" (cropped preview/save) mode, the pixel-sampling loop folded transforms (`foldTransforms = true`) to map output coordinates back to the source image, but the output canvas dimensions and preview canvas dimensions were kept at the unrotated crop size. This resulted in the rotated visual preview and saved outputs being severely clipped/cropped by the unrotated canvas boundaries.
4. **Layout Feedback Loop (Zooming/Cropping Bug)**: Measuring original display size dynamically using `offsetWidth`/`offsetHeight` of the hidden `img` element after clearing `wrapper.style.width`/`wrapper.style.height` was unstable. Due to the browser's layout engine handling container shrink-wrapping on elements styled with `width: 100%` / `max-width: 100%`, it would return the natural unconstrained size (e.g., `4000x3000`) instead of the true display size (e.g., `800x600`). This caused subsequent calculations to scale crop coordinates by an incorrect ratio, making the crop area shrink to a tiny top-left fraction and looking severely zoomed-in.
5. **Hidden Image Measurement Bug**: In the single uploader (`CreatePAEAuctionItem.cshtml`), switching to preview state sets the main image to `display: none`. This caused `getOriginalDisplaySize()` to return `w: 0, h: 0`, collapsing the wrapper and preview canvas to `0x0`.

## Resolution
1. Overrode `container.style.maxWidth = 'none'` and `container.style.maxHeight = 'none'` when adjustments are active, and cleared them on preview removal.
2. Maintained crop corner positions in untransformed space relative to `getOriginalDisplaySize()`.
3. Created helpers:
   - `getOriginalDisplaySize()` to get the unrotated display dimensions. Updated to compute the dimensions mathematically based on the viewport bounds and natural image dimensions rather than using dynamic DOM size resetting/measurement. This avoids layout thrashing and prevents layout feedback loop issues.
   - `getTransformedVisualPoint(...)` and `getTransformedVisualCorners()` to calculate transformed visual positions for rendering handles and polygons.
   - `getUntransformedPoint(...)` to map dragged visual handles back to untransformed space.
4. Simplified natural coordinate scale mapping in `bakeOutput()` and `cropAndSaveQuadrilateral()` to `state.cornerPositions[k].x * (natW / dispW)` as coordinates are now always untransformed.
5. In `renderLivePreview()` and `bakeOutput()`, when `hasTransform` is true, calculate the rotated canvas and container bounding box dimensions (`finalW`, `finalH`, `finalDispW`, `finalDispH`), and size the temp canvas `tmpC` and destination canvas accordingly. The pixel loop maps coordinates from the rotated destination size back to the unrotated crop/source space `[0, outW]` x `[0, outH]` for sampling, ensuring no part of the rotated content is clipped.

## Related Files
- `WebPortal/Pages/PhotoEditor.cshtml`
- `WebPortal/Pages/CreatePAEAuctionItem.cshtml`
