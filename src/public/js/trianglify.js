var pattern = Trianglify({
    width: window.innerWidth,
    height: window.innerHeight,
    cell_size: 30
    // x_colors: [],
    // y_colors: []
    // cell_size: 30+Math.random()*100
});
document.getElementById("trianglifyArea").appendChild(pattern.canvas());