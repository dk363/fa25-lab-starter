#include "game.h"

#include <stddef.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "./snake_utils.h"

/* Helper function definitions */
static void set_board_at(game_t *game, unsigned int row, unsigned int col, char ch);
static bool is_tail(char c);
static bool is_head(char c);
static bool is_snake(char c);
static char body_to_tail(char c);
static char head_to_body(char c);
static unsigned int get_next_row(unsigned int cur_row, char c);
static unsigned int get_next_col(unsigned int cur_col, char c);
static void find_head(game_t *game, unsigned int snum);
static char next_square(game_t *game, unsigned int snum);
static void update_tail(game_t *game, unsigned int snum);
static void update_head(game_t *game, unsigned int snum);

char** create_default_board(unsigned int rows, unsigned int cols) {
  char** board = (char**)malloc(rows * sizeof(char*));

  if (board != NULL) {
    for (int i = 0; i < rows; i++) {
      // In the last cols it will be '\n'
      board[i] = (char*)malloc((cols+2) * sizeof(char));
      if (board[i] == NULL) {
        for (int j = 0; j <= i; j++) {
          free(board[j]);
        }
        free(board);
        return NULL;
      }

      for (int j = 0; j < cols; j++) {
        if (i == 0 || i == rows-1 || j == 0 || j == cols-1) {
          board[i][j] = '#';
        } else {
          board[i][j] = ' ';
        }
      }
     
      board[i][cols] = '\n';
      board[i][cols+1] = '\0';
    }
  }

  return board;
}

/* Task 1 */
// Creat a default game. 
game_t *create_default_game() {
  game_t* game = (game_t*)malloc(sizeof(game_t));
  if (game == NULL) {
    return NULL;
  }
  
  game->num_rows = 18;
  // Default num of snakes
  game->num_snakes = 1;

  char** board = create_default_board(18, 20);
  if (board == NULL) {
    free_game(game);
    return NULL;
  }
  game->board = board;

  game->snakes = malloc(sizeof(snake_t) * game->num_snakes);
  if (game->snakes == NULL) {
    free_game(game);
    return NULL;
  }

  game->snakes[0].head_row = 2;
  game->snakes[0].head_col = 4;
  game->snakes[0].tail_row = 2;
  game->snakes[0].tail_col = 2;
  game->snakes[0].live = true;

  game->board[2][2] = 'd';
  game->board[2][3] = '>';
  game->board[2][4] = 'D';

  game->board[2][9] = '*';
  return game;
}

/* Task 2 */
// Free all memory allocated for the game
void free_game(game_t *game) {
  if (game == NULL) {
    return;
  }

  free(game->snakes);

  for (int i = 0; i < game->num_rows; i++) {
    free(game->board[i]);
  }
  free(game->board);

  free(game);
  
  return;
}

/* Task 3 */
void print_board(game_t *game, FILE *fp) {
  if (fp == NULL) {
    printf("can not open the file\n");
    return;
  }
  if (game == NULL) {
    printf("the game is NULL\n");
    return;
  }

  for (int i = 0; i < game->num_rows; i++) {
    int j = 0;
    while (game->board[i][j] != '\n') {
      fprintf(fp, "%c", game->board[i][j]);
      j++;
    }
    fprintf(fp, "%c", game->board[i][j]);
  }

  return;
}

/*
  Saves the current game into filename. Does not modify the game object.
  (already implemented for you).
*/
void save_board(game_t *game, char *filename) {
  FILE *f = fopen(filename, "w");
  print_board(game, f);
  fclose(f);
}

/* Task 4.1 */

/*
  Helper function to get a character from the board
  (already implemented for you).
*/
char get_board_at(game_t *game, unsigned int row, unsigned int col) { return game->board[row][col]; }

/*
  Helper function to set a character on the board
  (already implemented for you).
*/
static void set_board_at(game_t *game, unsigned int row, unsigned int col, char ch) {
  game->board[row][col] = ch;
}

static char tail[] = {
  'w', 'a', 's', 'd'
};

/*
  Returns true if c is part of the snake's tail.
  The snake consists of these characters: "wasd"
  Returns false otherwise.
*/
static bool is_tail(char c) {
  for (int i = 0; i < 4; i++) {
    if (c == tail[i]) {
      return true;
    }
  }
  return false;
}

static char head[] = {
  'W', 'A', 'S', 'D', 'x'
};
/*
  Returns true if c is part of the snake's head.
  The snake consists of these characters: "WASDx"
  Returns false otherwise.
*/
static bool is_head(char c) {
  for (int i = 0; i < 5; i++) {
    if (c == head[i]) {
      return true;
    }
  }
  return false;
}

static char body[] = { 
  '^', '<', 'v', '>' 
};
/*
  Return true if c is part of snake's body.
  The snake consits of these cahracters: "^<v>"
  Return false otherwise.
*/
static bool is_body(char c) {
    int n = sizeof(body) / sizeof(body[0]);
    for (int i = 0; i < n; i++) {
        if (c == body[i]) {
            return true;
        }
    }
    return false;
}

/*
  Returns true if c is part of the snake.
  The snake consists of these characters: "wasd^<v>WASDx"
*/
static bool is_snake(char c) {
  if (is_head(c) || is_tail(c) || is_body(c)) {
    return true;
  }
  return false;
}

/*
  Converts a character in the snake's body ("^<v>")
  to the matching character representing the snake's
  tail ("wasd").
*/
static char body_to_tail(char c) {
  switch (c) {
    case '^':
      return 'w';
    case '<':
      return 'a';
    case 'v':
      return 's';
    case '>':
      return 'd';
    default:
      return '?';
  }
}

/*
  Converts a character in the snake's head ("WASD")
  to the matching character representing the snake's
  body ("^<v>").
*/
static char head_to_body(char c) {
  switch (c) {
    case 'W':
      return '^';
    case 'A':
      return '<';
    case 'S':
      return 'v';
    case 'D':
      return '>';
    default:
      return '?';
  }
}

/*
  Returns cur_row + 1 if c is 'v' or 's' or 'S'.
  Returns cur_row - 1 if c is '^' or 'w' or 'W'.
  Returns cur_row otherwise.
*/
static unsigned int get_next_row(unsigned int cur_row, char c) {
  if (c == 'v' || c == 's' || c == 'S') {
    return cur_row + 1;
  } else if (c == '^' || c == 'w' || c == 'W') {
    return cur_row - 1;
  }
  return cur_row;
}

/*
  Returns cur_col + 1 if c is '>' or 'd' or 'D'.
  Returns cur_col - 1 if c is '<' or 'a' or 'A'.
  Returns cur_col otherwise.
*/
static unsigned int get_next_col(unsigned int cur_col, char c) {
  if (c == '>' || c == 'd' || c == 'D') {
    return cur_col + 1;
  } else if (c == '<' || c == 'a' || c == 'A') {
    return cur_col - 1;
  }
  return cur_col;
}

/*
  Task 4.2

  Helper function for update_game. Return the character in the cell the snake is moving into.

  This function should not modify anything.
*/
static char next_square(game_t *game, unsigned int snum) {
 char c = get_board_at(game, game->snakes[snum].head_row, game->snakes[snum].head_col);
 return get_board_at(game, get_next_row(game->snakes[snum].head_row, c), get_next_col(game->snakes[snum].head_col, c));
}

/*
  Task 4.3

  Helper function for update_game. Update the head...

  ...on the board: add a character where the snake is moving

  ...in the snake struct: update the row and col of the head

  Note that this function ignores food, walls, and snake bodies when moving the head.
*/
static void update_head(game_t *game, unsigned int snum) {
  char head = get_board_at(game, game->snakes[snum].head_row, game->snakes[snum].head_col);

  // update the old head
  set_board_at(game, game->snakes[snum].head_row, game->snakes[snum].head_col, head_to_body(head));

  // update the new head
  game->snakes[snum].head_row = get_next_row(game->snakes[snum].head_row, head);
  game->snakes[snum].head_col = get_next_col(game->snakes[snum].head_col, head);
  set_board_at(game, game->snakes[snum].head_row, game->snakes[snum].head_col, head);

  return;
}

/*
  Task 4.4

  Helper function for update_game. Update the tail...

  ...on the board: blank out the current tail, and change the new
  tail from a body character (^<v>) into a tail character (wasd)

  ...in the snake struct: update the row and col of the tail
*/
static void update_tail(game_t *game, unsigned int snum) {
  char old_tail = get_board_at(game, game->snakes[snum].tail_row, game->snakes[snum].tail_col);

  // update the old tail
  set_board_at(game, game->snakes[snum].tail_row, game->snakes[snum].tail_col, ' ');

  // update the new tail
  game->snakes[snum].tail_row = get_next_row(game->snakes[snum].tail_row, old_tail);
  game->snakes[snum].tail_col = get_next_col(game->snakes[snum].tail_col, old_tail);
  char old_tailed_body = get_board_at(game, game->snakes[snum].tail_row, game->snakes[snum].tail_col);

  set_board_at(game, game->snakes[snum].tail_row, game->snakes[snum].tail_col, body_to_tail(old_tailed_body));

  return;
}

// Detect the next cell is empty
static bool is_empty(game_t *game, unsigned int row, unsigned int col) {
  if (game->board[row][col] != ' ') {
    return false;
  } 

  // Next cell is not the ' ' of food 
  // It proves that the next cell is the other snakes' body or wall
  return true;
}


// Detect the next cell is empty
static bool is_food(game_t *game, unsigned int row, unsigned int col) {
  if (game->board[row][col] != '*') {
    return false;
  } 

  // Next cell is not the ' ' of food 
  // It proves that the next cell is the other snakes' body or wall
  return true;
}

/* Task 4.5 */
void update_game(game_t *game, int (*add_food)(game_t *game)) {
  for (unsigned int snum = 0; snum < game->num_snakes; snum++) {
    unsigned int cur_head_row = game->snakes[snum].head_row;
    unsigned int cur_head_col = game->snakes[snum].head_col;

    char head = game->board[cur_head_row][cur_head_col];
    unsigned int next_row = get_next_row(cur_head_row, head);
    unsigned int next_col = get_next_col(cur_head_col, head);

    if (!is_empty(game, next_row, next_col) && !is_food(game, next_row, next_col)) {
      set_board_at(game, cur_head_row, cur_head_col, 'x');
      game->snakes[snum].live = false;
    } else if (is_empty(game, next_row, next_col)){
      update_tail(game, snum);
      update_head(game, snum);
    } else {
      // is_food
      update_head(game, snum);
      add_food(game);
    }
  }
  return;
}

/* Task 5.1 */
char *read_line(FILE *fp) {
  if (fp == NULL) {
    return NULL;
  }

  size_t cap = 16; 
  size_t len = 0;
  char *buf = malloc(cap);
  if (buf == NULL) {
    return NULL;
  }
  char temp[16];

  int read_any = 0;
  
  while (fgets(temp, sizeof(temp), fp) != NULL) {
    read_any += 1;
    size_t chunk_len = strlen(temp);

    if (len + chunk_len + 1 > cap) {
      while (len + chunk_len + 1 > cap) {
        cap *= 2;
      }

      char *tmp = realloc(buf, cap);
      if (tmp == NULL) {
        free(buf);
        return NULL;
      }

      buf = tmp;
    }

    memcpy(buf + len, temp, chunk_len);
    len += chunk_len;
    
    if (chunk_len > 0 && temp[chunk_len-1] == '\n') {
      break;
    }
  }

  
  if (!read_any) {
    free(buf);
    return NULL;
  }
  
  buf[len] = '\0';
  return buf;
}

/* Task 5.2 */
game_t *load_board(FILE *fp) {
  game_t* game = (game_t*)malloc(sizeof(game_t));
  if (game == NULL) {
    return NULL;
  }

  game->board = NULL;
  game->num_rows = 0;
  game->num_snakes = 0;
  game->snakes = NULL;

  char *line;
  unsigned int row = 0;

  while ((line = read_line(fp)) != NULL) {
    char **new_board = realloc(game->board, sizeof(char *) * (row+1));
    if (new_board == NULL) {
      free(line);
      free_game(game);
      return NULL;
    }
    game->board = new_board;
    game->board[row] = line;

    row++;
    game->num_rows = row;
  }

  return game;
}

/*
  Task 6.1

  Helper function for initialize_snakes.
  Given a snake struct with the tail row and col filled in,
  trace through the board to find the head row and col, and
  fill in the head row and col in the struct.
*/
static void find_head(game_t *game, unsigned int snum) {
  unsigned int curr_row = game->snakes[snum].tail_row;
  unsigned int curr_col = game->snakes[snum].tail_col;
  
  char curr_ch = game->board[curr_row][curr_col];
  while (!is_head(game->board[curr_row][curr_col])) {
    unsigned int next_row = get_next_row(curr_row, curr_ch);
    unsigned int next_col = get_next_col(curr_col, curr_ch);

    curr_row = next_row;
    curr_col = next_col;    
    curr_ch = get_board_at(game, curr_row, curr_col);
  }

  // is_head
  game->snakes[snum].head_row = curr_row;
  game->snakes[snum].head_col = curr_col;

  return;
}

// Find the tail first, 
// then through the function find_head finding the head.
/* Task 6.2 */
game_t *initialize_snakes(game_t *game) {
  unsigned int snum = 0;
  for (unsigned int row = 0; row < game->num_rows; row++) {
    unsigned int col = 0; 

    while (game->board[row][col] != '\n') {
      if (is_tail(game->board[row][col])) {
        snake_t *new_snakes = realloc(game->snakes, sizeof(snake_t) * (snum + 1));
        if (new_snakes == NULL) {
          printf("initialize_snakes failed");
          free_game(game);
          return NULL; 
        }
        game->snakes = new_snakes;
        game->snakes[snum].tail_row = row;
        game->snakes[snum].tail_col = col;
        find_head(game, snum);

        game->snakes[snum].live = true;
        snum++;
      }
      col++;
    }
  }
  game->num_snakes = snum;
  return game;
}
