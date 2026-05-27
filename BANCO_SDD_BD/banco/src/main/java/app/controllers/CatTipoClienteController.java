package app.controllers;

import app.dto.ApiResponse;
import app.dto.CatTipoClienteRequestDto;
import app.dto.CatTipoClienteResponseDto;
import app.services.CatTipoClienteService;
import jakarta.validation.Valid;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/catalogos/tipos-clientes")
@RequiredArgsConstructor
public class CatTipoClienteController {

	private final CatTipoClienteService service;

	@GetMapping
	public ResponseEntity<ApiResponse<List<CatTipoClienteResponseDto>>> findAll() {
		return ResponseEntity.ok(ApiResponse.success("Tipos de cliente obtenidos correctamente", service.findAll(), "/api/catalogos/tipos-clientes"));
	}

	@GetMapping("/{idCatalogo}")
	public ResponseEntity<ApiResponse<CatTipoClienteResponseDto>> findById(@PathVariable Long idCatalogo) {
		return ResponseEntity.ok(ApiResponse.success("Tipo de cliente obtenido correctamente", service.findById(idCatalogo), "/api/catalogos/tipos-clientes/" + idCatalogo));
	}

	@PostMapping
	public ResponseEntity<ApiResponse<CatTipoClienteResponseDto>> create(@Valid @RequestBody CatTipoClienteRequestDto requestDto) {
		CatTipoClienteResponseDto response = service.create(requestDto);
		return ResponseEntity.status(HttpStatus.CREATED)
			.body(ApiResponse.success("Tipo de cliente creado correctamente", response, "/api/catalogos/tipos-clientes"));
	}

	@PutMapping("/{idCatalogo}")
	public ResponseEntity<ApiResponse<CatTipoClienteResponseDto>> update(@PathVariable Long idCatalogo, @Valid @RequestBody CatTipoClienteRequestDto requestDto) {
		return ResponseEntity.ok(ApiResponse.success("Tipo de cliente actualizado correctamente", service.update(idCatalogo, requestDto), "/api/catalogos/tipos-clientes/" + idCatalogo));
	}
}