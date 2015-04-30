var pattern = Trianglify({
    width: window.innerWidth,
    height: window.innerHeight,
    // x_colors: [],
    // y_colors: []
    cell_size: 30+Math.random()*100
});

document.getElementById("trianglifyArea").appendChild(pattern.canvas());

// Using colors.js here to get a complementary color
// Assuming that the middle of the array will hold the corresponding color for the
// cell in the middle of the screen. Checked and it seems to work
document.getElementById("homeHeader").style.color=$c.complement(pattern.polys[Math.floor((pattern.polys.length)/2)][0])