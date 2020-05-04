#include <stdio.h>
#include <stdlib.h>

#include <vector>
#include <map>
#include <string>


enum Identifier_type
{
    undefined,
    function,
    parameter,
    variable
};

struct Identifier
{
    Identifier(Identifier_type t, void* pd, std::string n) : type(t), pData(pd), name(n) {}
    Identifier_type type = Identifier_type::undefined;
    void* pData;
    std::string name;
};

struct function_data
{
    
    function_data(std::string n = "") : name(n){}
    std::string name;
    unsigned num_param = 0, num_var = 0;
};

class context
{
    std::vector<std::map<std::string, Identifier>> scopes;
    std::vector<function_data> func_list;
    function_data fun; //current function
public:
    context() = default;

    const Identifier& define(const std::string name, Identifier&& f) 
    {
        auto r = scopes.back().emplace(name, std::move(f));
        return r.first->second;
    }
    void def_param(){}

    Identifier& def_var(const std::string name) { define(name, Identifier(Identifier_type::variable, nullptr, name));}
    Identifier& def_param(const std::string name) { define(name, Identifier(Identifier_type::parameter, nullptr, name));}
    Identifier& def_func(const std::string name) { define(name, Identifier(Identifier_type::function, nullptr, name));}
    void Add_func(std::string name) { func_list.push_back(function_data(name)) ;}

    //operators
    void operator ++() { scopes.emplace_back();}
    void operator --() { scopes.pop_back();}


};