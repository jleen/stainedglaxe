import js.Browser;
import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;

class Vertex {
    public var x : Float;
    public var y : Float;

    public function new(x : Float, y : Float) {
        this.x = x;
        this.y = y;
    }
}

class Main {
    static var panes : Array<Array<Vertex>>;
    static var canvas : CanvasRenderingContext2D;

    static function main() {
        var c = cast(Browser.document.querySelector('#output'), CanvasElement);
        c.style.width = '${Browser.window.innerWidth}px';
        c.style.height = '${Browser.window.innerHeight}px';
        c.width = Std.parseInt(Browser.window.innerWidth) * 2;
        c.height = Std.parseInt(Browser.window.innerHeight) * 2;
        canvas = cast(c.getContext('2d'), CanvasRenderingContext2D);

        var initial = [
            new Vertex(0, 0),
            new Vertex(c.width, 0),
            new Vertex(c.width, c.height),
            new Vertex(0, c.height)
            ];
        panes = [ initial ];

        Browser.window.requestAnimationFrame(doFrame);
    }

    static function doFrame(delta : Float) {
        draw();
        Browser.window.requestAnimationFrame(doFrame);
    }

    static function convexCombination(u : Vertex, v: Vertex, d: Float) : Vertex {
        return new Vertex(u.x * d + v.x * (1-d),
                          u.y * d + v.y * (1-d));
    }

    static function drawSegment(u : Vertex, v: Vertex) {
        canvas.moveTo(u.x, u.y);
        canvas.lineTo(v.x, v.y);
        canvas.stroke();
    }

    static function randomInt(max) : Int {
        return Math.floor(Math.random() * max);
    }

    static function draw() {
        if (panes.length > 1000) return;
        var whichPane = randomInt(panes.length);
        var pane = panes[whichPane];
        var numVertices = pane.length;
        var whichVertex = randomInt(numVertices);
        var whichSide = Math.floor((whichVertex + (numVertices / 2)
                - (numVertices % 2 == 0 ? randomInt(2) : 0))
            % numVertices);  

        var cut = convexCombination(pane[whichSide],
                pane[(whichSide+1) % numVertices],
                Math.random());
        drawSegment(pane[whichVertex], cut);

        var pane1 = [ cut ];
        var i = whichVertex;
        while (i != (whichSide + 1) % numVertices) {
            pane1.push(pane[i]);
            i = (i+1) % numVertices;
        }

        var pane2 = [ cut ];

        i = (whichSide + 1) % numVertices;
        while (i != (whichVertex + 1) % numVertices) {
            pane2.push(pane[i]);
            i = (i+1) % numVertices;
        }

        panes[whichPane] = pane1;
        panes.push(pane2);
    }
}
