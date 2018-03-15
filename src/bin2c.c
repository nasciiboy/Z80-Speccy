/*
 * Unloved program to convert a binary on stdin to a C include on stdout
 * Jan 1999 Matt Mackall <mpm@selenic.com>
 *
 * This software may be used and distributed according to the terms
 * of the GNU General Public License, incorporated herein by reference.
 */
#include <stdio.h>

int main(int argc, char *argv[])
{
	int ch, total=0;

	if (argc > 1)
		printf("const char %s[%d] %s=\n", argv[1], argc > 2 ? argv[2] : "");

	do {
		printf("    ");
		while ((ch = getchar()) != EOF)
		{
			total++;
			printf("%3d, ",ch);
			if (total % 16 == 0)
				break;
		}
		printf("\n");
	} while (ch != EOF);

	if (argc > 1)
		printf("\t;\n\nconst int %s_size = %d;\n", argv[1], total);

	return 0;
}




