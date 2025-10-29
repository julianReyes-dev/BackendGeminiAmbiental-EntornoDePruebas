package com.gemini.gemini_ambiental.service;

import com.gemini.gemini_ambiental.dto.ProductoDTO;
import com.gemini.gemini_ambiental.entity.CategoriaProducto;
import com.gemini.gemini_ambiental.entity.Producto;
import com.gemini.gemini_ambiental.exception.ResourceNotFoundException;
import com.gemini.gemini_ambiental.repository.ProductoRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

/**
 * Pruebas Unitarias para ProductoService
 * Cobertura: RF4 (Registro Producto), RF5 (Control de Stock)
 * Técnicas: Partición de Equivalencia, Análisis de Valor Límite
 */
@ExtendWith(MockitoExtension.class)
@DisplayName("Pruebas Unitarias - ProductoService")
class ProductoServiceTest {

    @Mock
    private ProductoRepository productoRepository;

    @InjectMocks
    private ProductoService productoService;

    private Producto productoMock;
    private ProductoDTO productoDTOMock;
    private String idProducto;

    @BeforeEach
    void setUp() {
        idProducto = UUID.randomUUID().toString();
        
        // Crear producto mock
        productoMock = Producto.builder()
                .idProducto(idProducto)
                .nombre("Matarratas Test")
                .precioActual(new BigDecimal("45000.00"))
                .stock(50)
                .unidadMedida("unidad")
                .lote("TEST-001")
                .proveedor("Proveedor Test")
                .observaciones("Producto de prueba")
                .fechaCreacion(LocalDateTime.now())
                .build();

        // Crear DTO mock
        productoDTOMock = new ProductoDTO();
        productoDTOMock.setIdProducto(idProducto);
        productoDTOMock.setNombre("Matarratas Test");
        productoDTOMock.setPrecioActual(new BigDecimal("45000.00"));
        productoDTOMock.setStock(50);
        productoDTOMock.setUnidadMedida("unidad");
    }

    // ========== PRUEBAS DE CREACIÓN (RF4) ==========

    @Test
    @DisplayName("CP-U-P-001: Crear producto válido con todos los campos")
    void testCrearProductoValido() {
        // Arrange
        when(productoRepository.save(any(Producto.class))).thenReturn(productoMock);

        // Act
        ProductoDTO resultado = productoService.createProducto(productoDTOMock);

        // Assert
        assertNotNull(resultado);
        assertEquals("Matarratas Test", resultado.getNombre());
        assertEquals(new BigDecimal("45000.00"), resultado.getPrecioActual());
        assertEquals(50, resultado.getStock());
        verify(productoRepository, times(1)).save(any(Producto.class));
    }

    @Test
    @DisplayName("CP-U-P-002: Crear producto con precio en límite inferior (0)")
    void testCrearProductoPrecioLimiteInferior() {
        // Arrange - Análisis de Valor Límite (ABL)
        productoDTOMock.setPrecioActual(BigDecimal.ZERO);
        productoMock.setPrecioActual(BigDecimal.ZERO);
        when(productoRepository.save(any(Producto.class))).thenReturn(productoMock);

        // Act
        ProductoDTO resultado = productoService.createProducto(productoDTOMock);

        // Assert
        assertNotNull(resultado);
        assertEquals(BigDecimal.ZERO, resultado.getPrecioActual());
    }

    @Test
    @DisplayName("CP-U-P-003: Crear producto con stock en límite inferior (0)")
    void testCrearProductoStockCero() {
        // Arrange - ABL para stock
        productoDTOMock.setStock(0);
        productoMock.setStock(0);
        when(productoRepository.save(any(Producto.class))).thenReturn(productoMock);

        // Act
        ProductoDTO resultado = productoService.createProducto(productoDTOMock);

        // Assert
        assertNotNull(resultado);
        assertEquals(0, resultado.getStock());
    }

    // ========== PRUEBAS DE CONSULTA ==========

    @Test
    @DisplayName("CP-U-P-004: Obtener producto existente por ID")
    void testObtenerProductoPorId() {
        // Arrange
        when(productoRepository.findByIdWithCategory(idProducto))
                .thenReturn(Optional.of(productoMock));

        // Act
        ProductoDTO resultado = productoService.getProductoById(idProducto);

        // Assert
        assertNotNull(resultado);
        assertEquals(idProducto, resultado.getIdProducto());
        assertEquals("Matarratas Test", resultado.getNombre());
        verify(productoRepository, times(1)).findByIdWithCategory(idProducto);
    }

    @Test
    @DisplayName("CP-U-P-005: Obtener producto inexistente lanza excepción")
    void testObtenerProductoInexistente() {
        // Arrange
        String idInexistente = UUID.randomUUID().toString();
        when(productoRepository.findByIdWithCategory(idInexistente))
                .thenReturn(Optional.empty());

        // Act & Assert
        assertThrows(ResourceNotFoundException.class, () -> {
            productoService.getProductoById(idInexistente);
        });
        verify(productoRepository, times(1)).findByIdWithCategory(idInexistente);
    }

    @Test
    @DisplayName("CP-U-P-006: Obtener todos los productos")
    void testObtenerTodosLosProductos() {
        // Arrange
        Producto producto2 = Producto.builder()
                .idProducto(UUID.randomUUID().toString())
                .nombre("Producto 2")
                .precioActual(new BigDecimal("30000"))
                .stock(20)
                .build();
        
        when(productoRepository.findAll()).thenReturn(Arrays.asList(productoMock, producto2));

        // Act
        List<ProductoDTO> resultado = productoService.getAllProductos();

        // Assert
        assertNotNull(resultado);
        assertEquals(2, resultado.size());
        verify(productoRepository, times(1)).findAll();
    }

    // ========== PRUEBAS DE ACTUALIZACIÓN ==========

    @Test
    @DisplayName("CP-U-P-007: Actualizar producto existente")
    void testActualizarProducto() {
        // Arrange
        ProductoDTO actualizacionDTO = new ProductoDTO();
        actualizacionDTO.setNombre("Matarratas Actualizado");
        actualizacionDTO.setPrecioActual(new BigDecimal("50000"));
        actualizacionDTO.setStock(60);
        actualizacionDTO.setUnidadMedida("unidad");

        Producto productoActualizado = Producto.builder()
                .idProducto(idProducto)
                .nombre("Matarratas Actualizado")
                .precioActual(new BigDecimal("50000"))
                .stock(60)
                .unidadMedida("unidad")
                .build();

        when(productoRepository.findById(idProducto)).thenReturn(Optional.of(productoMock));
        when(productoRepository.save(any(Producto.class))).thenReturn(productoActualizado);

        // Act
        ProductoDTO resultado = productoService.updateProducto(idProducto, actualizacionDTO);

        // Assert
        assertNotNull(resultado);
        assertEquals("Matarratas Actualizado", resultado.getNombre());
        assertEquals(new BigDecimal("50000"), resultado.getPrecioActual());
        assertEquals(60, resultado.getStock());
        verify(productoRepository, times(1)).save(any(Producto.class));
    }

    // ========== PRUEBAS DE ELIMINACIÓN ==========

    @Test
    @DisplayName("CP-U-P-008: Eliminar producto existente")
    void testEliminarProducto() {
        // Arrange
        when(productoRepository.findById(idProducto)).thenReturn(Optional.of(productoMock));
        doNothing().when(productoRepository).delete(productoMock);

        // Act
        productoService.deleteProducto(idProducto);

        // Assert
        verify(productoRepository, times(1)).delete(productoMock);
    }

    @Test
    @DisplayName("CP-U-P-009: Eliminar producto inexistente lanza excepción")
    void testEliminarProductoInexistente() {
        // Arrange
        String idInexistente = UUID.randomUUID().toString();
        when(productoRepository.findById(idInexistente)).thenReturn(Optional.empty());

        // Act & Assert
        assertThrows(ResourceNotFoundException.class, () -> {
            productoService.deleteProducto(idInexistente);
        });
        verify(productoRepository, never()).delete(any());
    }

    // ========== PRUEBAS DE CONTEO (RF5 - Control de Stock) ==========

    @Test
    @DisplayName("CP-U-P-010: Contar productos disponibles (stock > 5)")
    void testContarProductosDisponibles() {
        // Arrange
        when(productoRepository.countByStockGreaterThan5()).thenReturn(25L);

        // Act
        Long resultado = productoService.countProductosDisponibles();

        // Assert
        assertEquals(25L, resultado);
        verify(productoRepository, times(1)).countByStockGreaterThan5();
    }

    @Test
    @DisplayName("CP-U-P-011: Contar productos con bajo stock (1-5)")
    void testContarProductosBajoStock() {
        // Arrange
        when(productoRepository.countByStockBetween1And5()).thenReturn(8L);

        // Act
        Long resultado = productoService.countProductosBajoStock();

        // Assert
        assertEquals(8L, resultado);
        verify(productoRepository, times(1)).countByStockBetween1And5();
    }

    @Test
    @DisplayName("CP-U-P-012: Contar productos agotados (stock = 0)")
    void testContarProductosAgotados() {
        // Arrange
        when(productoRepository.countByStockIsZero()).thenReturn(3L);

        // Act
        Long resultado = productoService.countProductosAgotados();

        // Assert
        assertEquals(3L, resultado);
        verify(productoRepository, times(1)).countByStockIsZero();
    }

    // ========== PRUEBAS DE BÚSQUEDA Y FILTRADO ==========

    @Test
    @DisplayName("CP-U-P-013: Buscar productos por término")
    void testBuscarProductosPorTermino() {
        // Arrange
        when(productoRepository.findAll()).thenReturn(Arrays.asList(productoMock));

        // Act
        List<ProductoDTO> resultado = productoService.searchProductos("Matarratas", null, null, null);

        // Assert
        assertNotNull(resultado);
        assertEquals(1, resultado.size());
        assertEquals("Matarratas Test", resultado.get(0).getNombre());
    }

    @Test
    @DisplayName("CP-U-P-014: Filtrar productos por estado 'agotado'")
    void testFiltrarProductosAgotados() {
        // Arrange
        Producto productoAgotado = Producto.builder()
                .idProducto(UUID.randomUUID().toString())
                .nombre("Producto Agotado")
                .precioActual(new BigDecimal("10000"))
                .stock(0)
                .build();
        
        when(productoRepository.findAll()).thenReturn(Arrays.asList(productoMock, productoAgotado));

        // Act
        List<ProductoDTO> resultado = productoService.searchProductos(null, null, "agotado", null);

        // Assert
        assertNotNull(resultado);
        assertEquals(1, resultado.size());
        assertEquals(0, resultado.get(0).getStock());
    }
}