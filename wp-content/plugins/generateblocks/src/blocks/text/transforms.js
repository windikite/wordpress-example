/**
 * WordPress dependencies
 */
import { createBlock } from '@wordpress/blocks';

const elementToLevel = { h1: 1, h2: 2, h3: 3, h4: 4, h5: 5, h6: 6 };
const levelToElement = { 1: 'h1', 2: 'h2', 3: 'h3', 4: 'h4', 5: 'h5', 6: 'h6' };

export const transforms = {
	from: [
		{
			type: 'block',
			blocks: [ 'core/paragraph' ],
			transform: ( { content } ) => {
				return createBlock( 'generateblocks/text', {
					content,
					tagName: 'p',
				} );
			},
		},
		{
			type: 'block',
			blocks: [ 'core/heading' ],
			transform: ( { content, level } ) => {
				return createBlock( 'generateblocks/text', {
					content,
					tagName: levelToElement[ level ],
				} );
			},
		},
	],
	to: [
		{
			type: 'block',
			blocks: [ 'core/paragraph' ],
			transform: ( { content } ) => {
				return createBlock( 'core/paragraph', {
					content,
				} );
			},
		},
		{
			type: 'block',
			blocks: [ 'core/heading' ],
			transform: ( { content, tagName } ) => {
				return createBlock( 'core/heading', {
					content,
					level: elementToLevel.hasOwnProperty( tagName ) ? elementToLevel[ tagName ] : 2,
				} );
			},
		},
	],
};
