Puppet::Functions.create_function(:role) do
  dispatch :main do
    param 'String', :role
  end

  def main(role)
    scope = closure_scope

    # Check if the function has already been called
    if scope.include? '_role'
      raise Puppet::ParseError, "role() can only be called once per node"
    end

    # Hack: we transform 'foo::bar' in 'foo/bar' so that it's easy to lookup in hiera
    scope['_role'] = role.gsub(/::/, '/')

    rolename = 'role::' + role
    call_function('include', rolename)
  end
end
