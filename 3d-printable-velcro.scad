// Parametric Printable Velcro Generator
// Enhanced and improved by Greg Kolens for better usability and publication as a remix
// Based on 'Printable Velcro' by MM Printing: https://www.printables.com/model/543802-printable-velcro
// Parametric SCAD version: https://www.printables.com/model/568587-parametric-3d-printable-velcro
// Original by eried: https://www.printables.com/model/33302-printable-velcro
//
// Original license:
//
// Written by Amarjeet Singh Kapoor <amarjeet.kapoor1@gmail.com>
//
// To the extent possible under law, the author(s) have dedicated all
// copyright and related and neighboring rights to this software to the
// public domain worldwide. This software is distributed without any
// warranty.
//
// You should have received a copy of the CC0 Public Domain
// Dedication along with this software.
// If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
//
// This remix is licensed under Creative Commons Attribution-NonCommercial 4.0 International
// License: https://creativecommons.org/licenses/by-nc/4.0/

/*[ Velcro Tower Elements ]*/

// Base diameter of each tower in mm (narrowest part)
Base_diameter = 1.0; //[0.5:0.1:5]

// Height multiplier for towers (height = Base_diameter * Height_multiplier)
Height_multiplier = 2.0; //[1.0:0.1:4.0]

// Top diameter multiplier (top_diameter = Base_diameter * Top_multiplier)
Top_multiplier = 1.3; //[1.1:0.1:2.0]

// Interference fit adjustment (-10 = tightest, 10 = loosest, 0 = original)
Interference = 0; //[-10:10]

/*[ Pattern Dimensions ]*/

// Desired width of the velcro pattern in mm
Width = 50; //[10:1:500]

// Desired length of the velcro pattern in mm  
Length = 50; //[10:1:500]

// Auto-adjust dimensions for proper velcro pattern ratio (recommended: true)
// When enabled, Length is automatically doubled to compensate for the 2:1 pattern ratio
Auto_adjust_dimensions = true; //[true, false]

/*[ Base Plate ]*/

// Thickness of the base plate in mm
Thickness = 0.6; //[0.2:0.1:5]

// Horizontal border offset from towers in mm
Border_horizontal = 5; //[1:1:100]

// Vertical border offset from towers in mm
Border_vertical = 5; //[1:1:100]

/*[ Quality Settings ]*/

// Number of fragments for cylinders (higher = smoother but slower)
Resolution = 8; //[5:100]

// Preview mode (faster rendering, lower quality)
Preview_mode = true; //[true, false]

// Maximum number of towers per dimension (prevents excessive geometry)
Max_towers_per_dimension = 50; //[10:1:100]

/*[ Hidden Parameters ]*/

$fn = Preview_mode ? 8 : Resolution;

// ===== CALCULATION FUNCTIONS =====

// Calculate top diameter based on base diameter
function Top_diameter() = Base_diameter * Top_multiplier;

// Calculate tower height
function Height() = Base_diameter * Height_multiplier;

// Calculate interference factor
function Interference_factor() = Base_diameter / 12.5;

// Calculate spacing between towers
function Spacing() = Base_diameter * 4.4 + Interference * Interference_factor();

// Calculate number of horizontal tower sets with safety limit
function Horizontal_count() = min(
    Max_towers_per_dimension,
    max(1, floor((Adjusted_width() - Border_horizontal * 2) / Spacing()))
);

// Calculate number of vertical tower sets with safety limit
function Vertical_count() = min(
    Max_towers_per_dimension,
    max(1, floor((Adjusted_length() - Border_vertical * 2) / (Spacing() / 2)))
);

// Auto-adjust dimensions for proper velcro pattern ratio
function Adjusted_width() = Auto_adjust_dimensions ? Width : Width;
function Adjusted_length() = Auto_adjust_dimensions ? Length * 2 : Length;

// Calculate actual pattern dimensions
function Actual_width() = Horizontal_count() * Spacing() + Border_horizontal * 2;
function Actual_length() = Vertical_count() * (Spacing() / 2) + Border_vertical * 2;

// ===== GEOMETRY MODULES =====

// Single tower geometry with optimized rendering
module tower() {
    cylinder(
        h = Height(), 
        r1 = Base_diameter / 2, 
        r2 = Top_diameter() / 2, 
        center = false,
        $fn = $fn
    );
}

// Single array of two towers (basic velcro unit)
module single_array() {
    h = Spacing();
    tower();
    translate([h / 2, h / 4, 0]) tower();
}

// Horizontal row of tower arrays
module horizontal_array() {
    h = Spacing();
    for (dx = [0 : h : h * (Horizontal_count() - 1)]) {
        translate([dx, 0, 0]) single_array();
    }
}

// Complete velcro pattern
module velcro_pattern() {
    v = Spacing() / 2;
    for (dy = [0 : v : v * (Vertical_count() - 1)]) {
        translate([0, dy, 0]) horizontal_array();
    }
}

// Base plate with proper dimensions
module base_plate() {
    h = Spacing();
    v = h / 2;
    
    // Calculate actual dimensions
    plate_width = h * Horizontal_count() + Border_horizontal * 2 - h / 2;
    plate_length = v * Vertical_count() + Border_vertical * 2 - v / 2;
    
    translate([-Border_horizontal, -Border_vertical, -Thickness]) 
        cube([plate_width, plate_length, Thickness]);
}

// ===== MAIN ASSEMBLY =====

// Show information in console
echo("=== Velcro Pattern Info ===");
echo("Desired dimensions:", Width, "x", Length, "mm");
if (Auto_adjust_dimensions) {
    echo("Auto-adjusted dimensions:", Adjusted_width(), "x", Adjusted_length(), "mm (for proper velcro ratio)");
}
echo("Actual dimensions:", Actual_width(), "x", Actual_length(), "mm");
echo("Tower count:", Horizontal_count(), "x", Vertical_count());
echo("Total towers:", Horizontal_count() * Vertical_count() * 2);
echo("Spacing:", Spacing(), "mm");
echo("Tower height:", Height(), "mm");
echo("Preview mode:", Preview_mode ? "ON" : "OFF");

// Warning if too many towers
total_towers = Horizontal_count() * Vertical_count() * 2;
if (total_towers > 1000) {
    echo("WARNING: Too many towers (", total_towers, "). Consider reducing dimensions or increasing spacing.");
}

// Main assembly
union() {
    velcro_pattern();
    base_plate();
}