<?php
/**
 * Ulmus functions and definitions.
 *
 * @link https://developer.wordpress.org/themes/basics/theme-functions/
 *
 * @package Ulmus
 */

if ( ! function_exists( 'ulmus_setup' ) ) :
	/**
	 * Sets up theme defaults and registers support for various WordPress features.
	 *
	 * Note that this function is hooked into the after_setup_theme hook, which
	 * runs before the init hook. The init hook is too late for some features, such
	 * as indicating support for post thumbnails.
	 */
	function ulmus_setup() {
		/*
		 * Make theme available for translation.
		 * Translations can be filed in the /languages/ directory.
		 * If you're building a theme based on Ulmus, use a find and replace
		 * to change 'ulmus' to the name of your theme in all the template files.
		 */
		 load_theme_textdomain( 'ulmus', get_template_directory(). '/languages' );

		 // Add default posts and comments RSS feed links to head.
		 add_theme_support( 'automatic-feed-links' );

		 /*
		  * Let WordPress manage the document title.
		  * By adding theme support, we declare that this theme does not use a
		  * hard-coded <title> tag in the document head, and expect WordPress to
		  * provide it for us.
		  */
		 add_theme_support( 'title-tag' );

		 /*
		  * Enable support for Post Thumbnails on posts and pages.
		  *
		  * @link https://developer.wordpress.org/themes/functionality/featured-images-post-thumbnails/
		  *
		  */
		 add_theme_support( 'post-thumbnails' );
	}
endif;
add_action( 'after_setup_theme', 'ulmus_setup' );

/**
 * Enqueue scripts and styles.
 */
function ulmus_scripts() {
	wp_enqueue_style( 'ulmus-style', get_stylesheet_uri() );

	wp_enqueue_script( 'ulmus-theme', get_template_directory_uri() . '/ulmus.js', array(), '20170118', true );
}
add_action( 'wp_enqueue_scripts', 'ulmus_scripts' );
