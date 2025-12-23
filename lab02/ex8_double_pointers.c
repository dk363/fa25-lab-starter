#include <stdio.h>
#include <stdlib.h>

typedef struct {
    int id;
    char *name;
} student_t;

typedef student_t * student_pointer;

student_t *create_student_1(int id) {
  student_t *student_ptr = malloc(sizeof(student_t));

  student_ptr->id = id;

  return student_ptr;
}

void create_student_2(student_t **student_double_ptr, int id) {
  // 这里相当于将地址擦掉然后写新房子的地址 所以我们失去了main函数中malloc的内存
  *student_double_ptr = malloc(sizeof(student_t));

  (*student_double_ptr)->id = id;
}


int main() {
  student_pointer student1_ptr = create_student_1(5);

  printf("Student 1's ID: %d\n", student1_ptr->id);

  free(student1_ptr);

  student_pointer student2_ptr = malloc(sizeof(student_t));
  
  student_pointer student3_ptr = student2_ptr;

  student_pointer *double_ptr = &student2_ptr;

  create_student_2(double_ptr, 6);


  printf("Student 2's ID: %d\n", student2_ptr->id);

  free(student3_ptr);
  free(student2_ptr);

  return 0;
}
