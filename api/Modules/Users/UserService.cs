using System.Net;
using Microsoft.EntityFrameworkCore;
using api.DB;
using api.Modules.Users.Dto;
using api.Modules.Users.Entity;

namespace api.Modules.Users;

public static class UserService
{

  public static async Task<ResponseUserDTO> CreateUser(RequestCreateUserDto request, ApiDbContext context, CancellationToken ct)
  {
    if (string.IsNullOrWhiteSpace(request.Name) ||
        string.IsNullOrWhiteSpace(request.Password) ||
        string.IsNullOrWhiteSpace(request.Phone))
    {
      return new ResponseUserDTO(
          HttpStatusCode.BadRequest,
          null,
          "All fields are required");
    }

    if (!request.Email.Contains("@") || !request.Email.Contains("."))
    {
      return new ResponseUserDTO(
          HttpStatusCode.BadRequest,
          null,
          "Invalid email format");
    }

    // Verifica se já existe um usuário com este email, ativo ou inativo
    var existingUser = await context.Users.SingleOrDefaultAsync(u => u.Email == request.Email, ct);

    if (existingUser != null)
    {
      if (existingUser.IsActive) // Supondo que você tenha uma propriedade IsActive na sua entidade User
      {
        return new ResponseUserDTO(
            HttpStatusCode.Conflict,
            null,
            "User with this email already exists and is active");
      }
      else
      {
        existingUser.SetActive(true);
        existingUser.SetName(request.Name);
        existingUser.SetPassword(request.Password);
        existingUser.SetPhone(request.Phone);
        existingUser.UpdateTimestamps();

        context.Users.Update(existingUser);
        await context.SaveChangesAsync(ct);

        var responseUser = new ResponseEntityUserDTO(
            existingUser.Id,
            existingUser.Name,
            existingUser.Email,
            existingUser.Phone,
            existingUser.CreatedAt // Mantém o CreatedAt original
        );

        return new ResponseUserDTO(
            HttpStatusCode.Created,
            responseUser,
            "User reactivated and updated successfully");
      }
    }

    // Se não existe nenhum usuário com este email (ativo ou inativo), cria um novo
    var user = new User(request.Name, request.Email, request.Password, request.Phone);
    await context.Users.AddAsync(user, ct);
    await context.SaveChangesAsync(ct);

    return new ResponseUserDTO(
        HttpStatusCode.Created,
        null,
        "User created successfully");
  }

  public static async Task<ResponseUserDTO> GetUserById(Guid id, ApiDbContext context, CancellationToken ct)
  {
    // Alterado para buscar apenas usuários ativos, se for a sua regra de negócio
    var user = await context.Users.SingleOrDefaultAsync(u => u.Id == id && u.IsActive, ct);

    if (user == null)
    {
      return new ResponseUserDTO(
          HttpStatusCode.NotFound,
          null,
          "User not found or is inactive");
    }

    var responseUser = new ResponseEntityUserDTO(
        user.Id,
        user.Name,
        user.Email,
        user.Phone,
        user.CreatedAt
    );

    return new ResponseUserDTO(
        HttpStatusCode.OK,
        responseUser,
        "User retrieved successfully"
        );
  }

  public static async Task<ResponseUserListDTO> GetAllUsers(ApiDbContext context, CancellationToken ct)
  {
    // Alterado para buscar apenas usuários ativos
    var users = await context.Users
        .Where(u => u.IsActive) // Filtra apenas usuários ativos
        .Select(u => new ResponseEntityUserDTO(
            u.Id,
            u.Name,
            u.Email,
            u.Phone,
            u.CreatedAt
        )).ToListAsync(ct);

    if (users.Count == 0)
    {
      return new ResponseUserListDTO(
          HttpStatusCode.NotFound,
          0,
          null,
          "No active users found"
      );
    }

    return new ResponseUserListDTO(
        HttpStatusCode.OK,
        users.Count,
        users,
        "Active users retrieved successfully"
    );
  }

  public static async Task<ResponseUserDTO> UpdateUser(Guid id, RequestUpdateUserDto request, ApiDbContext context, CancellationToken ct)
  {
    // Busque o usuário, considerando que ele pode estar inativo
    var user = await context.Users.SingleOrDefaultAsync(u => u.Id == id, ct);

    if (user == null)
    {
      return new ResponseUserDTO(
          HttpStatusCode.NotFound,
          null,
          "User not found");
    }

    if (!user.IsActive)
    {
      return new ResponseUserDTO(
          HttpStatusCode.Forbidden, // Ou outro código apropriado, como HttpStatusCode.BadRequest
          null,
          "Cannot update an inactive user. Please reactivate first.");
    }


    if (request.Name != null) user.SetName(request.Name);
    if (request.Email != null)
    {
      if (!request.Email.Contains("@") || !request.Email.Contains("."))
      {
        return new ResponseUserDTO(
            HttpStatusCode.BadRequest,
            null,
            "Invalid email format");
      }

      // Ao verificar se o email já existe para outro usuário, considere apenas usuários ativos
      var emailExists = await context.Users.AnyAsync(u => u.Email == request.Email && u.Id != id && u.IsActive, ct);
      if (emailExists)
      {
        return new ResponseUserDTO(
            HttpStatusCode.Conflict,
            null,
            "User with this email already exists");
      }

      user.SetEmail(request.Email);
    }
    if (request.Password != null) user.SetPassword(request.Password); // Lembre-se de hash a senha
    if (request.Phone != null) user.SetPhone(request.Phone);

    user.UpdateTimestamps();

    context.Users.Update(user);
    await context.SaveChangesAsync(ct);

    var responseUser = new ResponseEntityUserDTO(
        user.Id,
        user.Name,
        user.Email,
        user.Phone,
        user.CreatedAt
    );

    return new ResponseUserDTO(
        HttpStatusCode.OK,
        responseUser,
        "User updated successfully"
    );
  }

  public static async Task<ResponseUserDTO> DeleteUser(Guid id, ApiDbContext context, CancellationToken ct)
  {
    var user = await context.Users.SingleOrDefaultAsync(u => u.Id == id, ct);

    if (user == null)
    {
      return new ResponseUserDTO(
          HttpStatusCode.NotFound,
          null,
          "User not found");
    }

    if (!user.IsActive) // Evita "deletar" um usuário que já está inativo
    {
      return new ResponseUserDTO(
          HttpStatusCode.OK, // Já está inativo, então a "deleção" lógica já ocorreu
          null,
          "User is already inactive");
    }

    user.SetActive(false); // Marca como inativo/deletado logicamente
    user.UpdateTimestamps();

    await context.SaveChangesAsync(ct);

    return new ResponseUserDTO(
        HttpStatusCode.OK,
        null,
        "User deactivated successfully"
    );
  }

}