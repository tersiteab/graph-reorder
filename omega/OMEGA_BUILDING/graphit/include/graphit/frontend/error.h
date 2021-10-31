//
// Created by Yunming Zhang on 3/22/17.
//

#ifndef GRAPHIT_ERROR_H
#define GRAPHIT_ERROR_H


#ifndef SIMIT_DIAGNOSTICS_H
#define SIMIT_DIAGNOSTICS_H

#include <exception>
#include <string>
#include <vector>
#include <iostream>

#include <graphit/utils/util.h>

namespace graphit {

    class SimitException : public std::exception {
    public:
        SimitException() : hasContext(false) {
            errStringStream << " IR stack:" << std::endl;
        }

        SimitException(SimitException&& other) : hasContext(false) {
            errStringStream << other.errStringStream.str();
        }

        virtual const char* what() const throw() {
            return (hasContext) ? errStringStream.str().c_str() : "";
        }

        // Resets context stream cutoff, and inserts string context description
        void addContext(std::string contextDesc) {
            errStringStream << " ... " << util::split(contextDesc,"\n")[0] << std::endl;
            hasContext = true;
        }

    private:
        std::stringstream errStringStream;
        bool hasContext;
    };

/// Provides information about errors that occur while loading Simit code.
    class ParseError {
    public:
        ParseError(int firstLine, int firstColumn, int lastLine, int lastColumn,
                   std::string msg);
        virtual ~ParseError();

        int getFirstLine() { return firstLine; }
        int getFirstColumn() { return firstColumn; }
        int getLastLine() { return lastLine; }
        int getLastColumn() { return lastColumn; }
        const std::string &getMessage() { return msg; }

        std::string toString() const;
        friend std::ostream &operator<<(std::ostream &os, const ParseError &obj) {
            return os << obj.toString();
        }
        bool operator<(const ParseError &rhs) const {
            return ((firstLine < rhs.firstLine) ||
                    ((firstLine == rhs.firstLine) && (firstColumn < rhs.firstColumn)));
        }

    private:
        int firstLine;
        int firstColumn;
        int lastLine;
        int lastColumn;
        std::string msg;
        std::string line;  // TODO
    };

    class Diagnostic {
    public:
        Diagnostic() {}

        Diagnostic &operator<<(const std::string &str) {
            msg += str;
            return *this;
        }

        std::string getMessage() const { return msg; }

    private:
        std::string msg;
    };

    class Diagnostics {
    public:
        Diagnostics() {}
        ~Diagnostics() {}

        Diagnostic &report() {
            diags.push_back(Diagnostic());
            return diags[diags.size()-1];
        }

        bool hasErrors() {
            return diags.size() > 0;
        }

        std::string getMessage(const std::string prefix = "") const {
            std::string result;
            auto it = diags.begin();
            if (it != diags.end()) {
                result += prefix + it->getMessage();
                ++it;
            }
            while (it != diags.end()) {
                result += "\n" + prefix + it->getMessage();
                ++it;
            }
            return result;
        }

        std::vector<Diagnostic>::const_iterator begin() const { return diags.begin();}
        std::vector<Diagnostic>::const_iterator end() const { return diags.end(); }

    private:
        std::vector<Diagnostic> diags;
    };

    std::ostream &operator<<(std::ostream &os, const Diagnostics &f);


    namespace internal {

        struct ErrorReport {
            enum Kind { User, Internal, Temporary };

            std::ostringstream *msg;
            const char *file;
            const char *func;
            int line;

            bool condition;
            const char *conditionString;

            Kind kind;
            bool warning;

            ErrorReport(const char *file, const char *func, int line, bool condition,
                        const char *conditionString, Kind kind, bool warning);

            template<typename T>
            ErrorReport &operator<<(T x) {
                if (condition) {
                    return *this;
                }
                (*msg) << x;
                return *this;
            }

            // Support for manipulators, such as std::endl
            ErrorReport &operator<<(std::ostream& (*manip)(std::ostream&)) {
                if (condition) {
                    return *this;
                }
                (*msg) << manip;
                return *this;
            }

            ~ErrorReport() noexcept(false) {
                if (condition) {
                    return;
                }
                explode();
            }

            void explode();
        };

// internal asserts
#ifdef SIMIT_ASSERTS
        #define iassert(c)                                                           \
    simit::internal::ErrorReport(__FILE__, __FUNCTION__, __LINE__, (c), #c,    \
                               simit::internal::ErrorReport::Internal, false)
  #define ierror                                                               \
    simit::internal::ErrorReport(__FILE__, __FUNCTION__, __LINE__, false, NULL,\
                               simit::internal::ErrorReport::Internal, false)
#else
        struct Dummy {
            template<typename T>
            Dummy &operator<<(T x) {
                return *this;
            }
            // Support for manipulators, such as std::endl
            Dummy &operator<<(std::ostream& (*manip)(std::ostream&)) {
                return *this;
            }
        };

#define iassert(c) simit::internal::Dummy()
#define ierror simit::internal::Dummy()
#endif

#define unreachable                                                            \
  std::cout << "reached unreachable location" << std::endl;

// internal assert helpers
#define iassert_scalar(a)                                                      \
  iassert(isScalar(a.type())) << a << ": " << a.type()

#define iassert_types_equal(a,b)                                               \
  iassert(a.type() == b.type()) << a.type() << " != " << b.type() << "\n"      \
                                << #a << ": " << a << "\n" << #b << ": " << b

#define iassert_int_scalar(a)                                                  \
  iassert(isScalar(a.type()) && isInt(a.type()))                               \
      << a << "must be an int scalar but is a" << a.type()

#define iassert_boolean_scalar(a)                                              \
  iassert(isScalar(a.type()) && isBoolean(a.type()))                           \
      << a << "must be a boolean scalar but is a" << a.type()

// User asserts
#define uassert(c)                                                             \
  simit::internal::ErrorReport(__FILE__,__FUNCTION__,__LINE__, (c), #c,        \
                               simit::internal::ErrorReport::User, false)
#define uerror                                                                 \
  simit::internal::ErrorReport(__FILE__,__FUNCTION__,__LINE__, false, nullptr, \
                               simit::internal::ErrorReport::User, false)
#define uwarning                                                               \
  simit::internal::ErrorReport(__FILE__,__FUNCTION__,__LINE__, false, nullptr, \
                               simit::internal::ErrorReport::User, true)

// Temporary assertions (planned for the future)
#define tassert(c)                                                             \
  simit::internal::ErrorReport(__FILE__, __FUNCTION__, __LINE__, (c), #c,      \
                               simit::internal::ErrorReport::Temporary, false)
#define terror                                                                 \
  simit::internal::ErrorReport(__FILE__, __FUNCTION__, __LINE__, false, NULL,  \
                               simit::internal::ErrorReport::Temporary, false)

#define not_supported_yet terror

    }}

#endif





#endif //GRAPHIT_ERROR_H
