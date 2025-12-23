[guide](https://cs61c.org/fa25/labs/lab02/#exercise-9-reflection-and-feedback-form)
d
# C Debugging

不要忘记 print 也是一个好帮手

## GDB

## Valgrind

画图是一种很好的调试指针错误的方式 
关于 c 和 指针 不得不提到 cs50 当初看的时候没看出来课上的好 
但是其实讲的很细 很透彻 如果好好上的话 可以打下很好的基础

总结 先用 GDB 找出来大概是哪里的问题 单步调试

但是内存泄露的问题是 GDB 找不出来的 由于 c 太底层了 可以让我们随意操控内存 所以这种问题也十分棘手

这里就要用到 Valgrind 这个工具

```shell
➜  lab02 git:(main) ✗ gcc -g -o ex8 ex8_double_pointers.c
➜  lab02 git:(main) ✗ valgrind ./ex8 
```

> NOTE: Don't forget the -g flag

这个时候终端上会有一大堆 东西 我们啥也不管 只看最上面的报错信息

还是找不出来？

往下看会有一个 summary 仔细看 summary 
这里会告诉我们 allocate 和 free 的次数

还是找不出来？

```shell
➜  lab02 git:(main) ✗ valgrind ./ex8 --leak-check=full   
```

这个命令会告诉我们详细信息 

但是有时候 valgrind 也不会告诉我们真的发生错误的具体 function （是在那里 但又不是在那里，问题发生在那里 但是错误不在那里）

比方说看到 `ex7_vactor.c` 的 [66行](./ex7_vector.c#L66) 将这一行改为

```c
    retval->data = 0;
```

那么valgrind 会显示错误出现在 get 函数中

```shell
Calling vector_new()
Calling vector_delete()
vector_new() again
==85973== Invalid read of size 4
==85973==    at 0x1093EA: vector_get (ex7_vector.c:85)
==85973==    by 0x109589: main (ex7_test_vector.c:18)
==85973==  Address 0x0 is not stack'd, malloc'd or (recently) free'd
==85973== 
==85973== 
```

但是因为构造函数本身就是错的 只是恰好可以 return 一个可以蒙混过关的结构体

实际上从构造函数开始就是错的

这就非常棘手 如果反复看 get 函数 是看不出来错误的

那么这时候就要一个一个向前看 看哪一些 function 和 get 有关 

一步一步向上看

当然了 我在写的时候完全看不出来是这里有问题 这个时候 小组coding 就很重要 :( 我只有在 AI 大人的帮助下才完成了debug
