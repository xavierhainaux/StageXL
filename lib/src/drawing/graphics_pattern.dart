part of stagexl.drawing;

class GraphicsPattern {

  final RenderTextureQuad renderTextureQuad;
  final Matrix matrix;
  final String repeatOption;

  GraphicsPattern.repeat(this.renderTextureQuad, [this.matrix])
      : repeatOption = "repeat";

  GraphicsPattern.repeatX(this.renderTextureQuad, [this.matrix])
      : repeatOption = "repeat-x";

  GraphicsPattern.repeatY(this.renderTextureQuad, [this.matrix])
      : repeatOption = "repeat-y";

  GraphicsPattern.noRepeat(this.renderTextureQuad, [this.matrix])
      : repeatOption = "no-repeat";

  //---------------------------------------------------------------------------

  CanvasPattern getCanvasPattern(CanvasRenderingContext2D context) {
    var renderTexture = renderTextureQuad.renderTexture;

    var source = renderTexture.source;
    if (source is ImageElement) {
      return context.createPatternFromImage(source, repeatOption);
    } else {
      return context.createPattern(source, repeatOption);
    }
  }
}
