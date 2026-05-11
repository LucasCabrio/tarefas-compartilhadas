package br.edu.tarefascompartilhadas.repository;

import br.edu.tarefascompartilhadas.enums.StatusAmizade;
import br.edu.tarefascompartilhadas.model.Amizade;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface AmizadeRepository extends JpaRepository<Amizade, Long> {

    @Query("""
            select case when count(a) > 0 then true else false end
            from Amizade a
            where (a.usuarioSolicitante.id = :usuarioAId and a.usuarioAmigo.id = :usuarioBId)
               or (a.usuarioSolicitante.id = :usuarioBId and a.usuarioAmigo.id = :usuarioAId)
            """)
    boolean existsByUsuarios(@Param("usuarioAId") Long usuarioAId, @Param("usuarioBId") Long usuarioBId);

    @Query("""
            select case when count(a) > 0 then true else false end
            from Amizade a
            where a.statusAmizade = :status
              and (
                   (a.usuarioSolicitante.id = :usuarioAId and a.usuarioAmigo.id = :usuarioBId)
                or (a.usuarioSolicitante.id = :usuarioBId and a.usuarioAmigo.id = :usuarioAId)
              )
            """)
    boolean existsByUsuariosAndStatus(
            @Param("usuarioAId") Long usuarioAId,
            @Param("usuarioBId") Long usuarioBId,
            @Param("status") StatusAmizade status
    );

    @Query("""
            select a
            from Amizade a
            where a.statusAmizade = :status
              and (a.usuarioSolicitante.id = :usuarioId or a.usuarioAmigo.id = :usuarioId)
            """)
    List<Amizade> findByUsuarioIdAndStatus(
            @Param("usuarioId") Long usuarioId,
            @Param("status") StatusAmizade status
    );

    List<Amizade> findByUsuarioAmigoIdAndStatusAmizade(Long usuarioId, StatusAmizade statusAmizade);
}
