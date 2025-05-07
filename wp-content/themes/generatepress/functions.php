<?php
/**
 * GeneratePress.
 *
 * Please do not make any edits to this file. All edits should be done in a child theme.
 *
 * @package GeneratePress
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit; // Exit if accessed directly.
}

// Set our theme version.
define( 'GENERATE_VERSION', '3.6.0' );

if ( ! function_exists( 'generate_setup' ) ) {
	add_action( 'after_setup_theme', 'generate_setup' );
	/**
	 * Sets up theme defaults and registers support for various WordPress features.
	 *
	 * @since 0.1
	 */
	function generate_setup() {
		// Make theme available for translation.
		load_theme_textdomain( 'generatepress' );

		// Add theme support for various features.
		add_theme_support( 'automatic-feed-links' );
		add_theme_support( 'post-thumbnails' );
		add_theme_support( 'post-formats', array( 'aside', 'image', 'video', 'quote', 'link', 'status' ) );
		add_theme_support( 'woocommerce' );
		add_theme_support( 'title-tag' );
		add_theme_support( 'html5', array( 'search-form', 'comment-form', 'comment-list', 'gallery', 'caption', 'script', 'style' ) );
		add_theme_support( 'customize-selective-refresh-widgets' );
		add_theme_support( 'align-wide' );
		add_theme_support( 'responsive-embeds' );

		$color_palette = generate_get_editor_color_palette();

		if ( ! empty( $color_palette ) ) {
			add_theme_support( 'editor-color-palette', $color_palette );
		}

		add_theme_support(
			'custom-logo',
			array(
				'height' => 70,
				'width' => 350,
				'flex-height' => true,
				'flex-width' => true,
			)
		);

		// Register primary menu.
		register_nav_menus(
			array(
				'primary' => __( 'Primary Menu', 'generatepress' ),
			)
		);

		/**
		 * Set the content width to something large
		 * We set a more accurate width in generate_smart_content_width()
		 */
		global $content_width;
		if ( ! isset( $content_width ) ) {
			$content_width = 1200; /* pixels */
		}

		// Add editor styles to the block editor.
		add_theme_support( 'editor-styles' );

		$editor_styles = apply_filters(
			'generate_editor_styles',
			array(
				'assets/css/admin/block-editor.css',
			)
		);

		add_editor_style( $editor_styles );
	}
}

/**
 * Get all necessary theme files
 */
$theme_dir = get_template_directory();

require $theme_dir . '/inc/theme-functions.php';
require $theme_dir . '/inc/defaults.php';
require $theme_dir . '/inc/class-css.php';
require $theme_dir . '/inc/css-output.php';
require $theme_dir . '/inc/general.php';
require $theme_dir . '/inc/customizer.php';
require $theme_dir . '/inc/markup.php';
require $theme_dir . '/inc/typography.php';
require $theme_dir . '/inc/plugin-compat.php';
require $theme_dir . '/inc/block-editor.php';
require $theme_dir . '/inc/class-typography.php';
require $theme_dir . '/inc/class-typography-migration.php';
require $theme_dir . '/inc/class-html-attributes.php';
require $theme_dir . '/inc/class-theme-update.php';
require $theme_dir . '/inc/class-rest.php';
require $theme_dir . '/inc/deprecated.php';

if ( is_admin() ) {
	require $theme_dir . '/inc/meta-box.php';
	require $theme_dir . '/inc/class-dashboard.php';
}

/**
 * Load our theme structure
 */
require $theme_dir . '/inc/structure/archives.php';
require $theme_dir . '/inc/structure/comments.php';
require $theme_dir . '/inc/structure/featured-images.php';
require $theme_dir . '/inc/structure/footer.php';
require $theme_dir . '/inc/structure/header.php';
require $theme_dir . '/inc/structure/navigation.php';
require $theme_dir . '/inc/structure/post-meta.php';
require $theme_dir . '/inc/structure/sidebars.php';
require $theme_dir . '/inc/structure/search-modal.php';


// Etsy RSS Feed Shortcode (with Price)
function etsy_feed_shortcode( $atts ) {
	$atts = shortcode_atts( [
	  'url'   => '',
	  'count' => 6,
	], $atts, 'etsy_feed' );
  
	if ( empty( $atts['url'] ) ) {
	  return '<p>No feed URL provided.</p>';
	}
  
	include_once ABSPATH . WPINC . '/feed.php';
	$rss = fetch_feed( $atts['url'] );
	if ( is_wp_error( $rss ) ) {
	  return '<p>Unable to fetch feed.</p>';
	}
  
	$max   = $rss->get_item_quantity( $atts['count'] );
	$items = $rss->get_items( 0, $max );
  
	$output = '<div class="etsy-feed-grid">';
	foreach ( $items as $item ) {
		$content = $item->get_content();
	
		// IMAGE (unchanged)
		preg_match( '/<img.*?src=[\'"]([^\'"]+)/i', $content, $imgm );
		$img = isset($imgm[1]) ? esc_url($imgm[1]) : '';
	
		// PRICE: look for <p class="price">PRICE TEXT</p>
		if ( preg_match( '/<p\s+class="price"\s*>([^<]+)<\/p>/', $content, $pm ) ) {
			$price = esc_html( trim( $pm[1] ) );
		} else {
			$price = '';
		}
	
		// LINK & TITLE (unchanged)
		$link  = esc_url( $item->get_permalink() );
		$title = esc_html( $item->get_title() );
	
		// OUTPUT
		$output .= '<div class="etsy-feed-item">';
		$output .=   '<a href="' . $link . '" target="_blank">';
		if ( $img ) {
			$output .= '<img src="' . $img . '" alt="' . $title . '"/>';
		}
		$output .=   '</a>';
		$output .=   '<h4><a href="' . $link . '" target="_blank">' . $title . '</a></h4>';
		if ( $price ) {
			$output .= '<p class="etsy-feed-price">' . $price . '</p>';
		}
		$output .= '</div>';
	}
	
	$output .= '</div>';
  
	return $output;
  }
  add_shortcode( 'etsy_feed', 'etsy_feed_shortcode' );
  