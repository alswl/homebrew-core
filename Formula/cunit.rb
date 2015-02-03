class Cunit < Formula
  homepage "http://cunit.sourceforge.net/"
  url "https://downloads.sourceforge.net/project/cunit/CUnit/2.1-3/CUnit-2.1-3.tar.bz2"
  sha1 "eac0c71167aa3fab83483ae1313b78163f0f7238"

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build

  def install
    inreplace "bootstrap", "libtoolize", "glibtoolize"
    system "sh", "bootstrap", prefix
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      #include <stdio.h>
      #include <string.h>
      #include "CUnit/Basic.h"

      int noop(void) { return 0; }

      void test42(void) { CU_ASSERT(42 == 42); }

      int main(void)
      {
         CU_pSuite pSuite = NULL;
         if (CUE_SUCCESS != CU_initialize_registry())
            return CU_get_error();
         pSuite = CU_add_suite("Suite_1", noop, noop);
         if (NULL == pSuite) {
            CU_cleanup_registry();
            return CU_get_error();
         }
         if (NULL == CU_add_test(pSuite, "test of 42", test42)) {
            CU_cleanup_registry();
            return CU_get_error();
         }
         CU_basic_set_mode(CU_BRM_VERBOSE);
         CU_basic_run_tests();
         CU_cleanup_registry();
         return CU_get_error();
      }
    EOS

    system ENV.cc, "test.c", "-L#{lib}", "-lcunit", "-o", "test"
    assert_match "test of 42 ...passed", shell_output("./test")
  end
end
